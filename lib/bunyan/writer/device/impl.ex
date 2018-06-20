defmodule Bunyan.Writer.Device.Impl do

  alias Bunyan.Writer.Device.SignalHandler

  @doc false
  def write_to_device(options, msg) do
    IO.write(options.device_pid, options.format_function.(msg) |> List.flatten |> Enum.join)
  end

  @doc false
  @spec set_log_device(config :: map, device :: Bunyan.Writer.Device.t) :: map
  def set_log_device(config, device) do
    pid_or_process_name = maybe_open_file(device)

    config
    |> maybe_close_existing_file()
    |> setup_new_device(pid_or_process_name, device)
    |> maybe_setup_signal_handler()
    |> maybe_enable_color_logging()
  end

  @doc """
  Close the currently open log file. Called if this process
  terminates, and sometimes by the tests. You probaby won't have to
  use this.
  """
  def close_log_device(options) do
    maybe_close_existing_file(options)
  end

  @doc false
  @spec bounce_log_file(map()) :: map()
  def bounce_log_file(options = %{ device: device }) when is_binary(device) do
    options = maybe_close_existing_file(options)
    pid = open_log_file(device)
    setup_new_device(options, pid, device)
  end

  def bounce_log_file(options) do
    options
  end



  defp maybe_open_file(device) when is_atom(device) do
    device
  end

  defp maybe_open_file(name) when is_binary(name) do
    open_log_file(name)
  end

  defp maybe_open_file(other) do
    raise """
    In call to `Bunyan.Writer.Device(#{inspect other})`:

        expected the parameter to be the name or pid of an IO handler (such as
        :standard_error) or a file name.
    """
  end



  defp maybe_close_existing_file(config = %{ device: name, device_pid: pid })
  when is_binary(name) and is_pid(pid) do
    File.close(pid)
    %{ config | device: nil, device_pid: nil }
  end

  defp maybe_close_existing_file(config) do
    config
  end




  defp setup_new_device(config, pid_or_process_name, file_name) when is_binary(file_name) do
    %{ config | device_pid: pid_or_process_name, device: file_name }
  end

  defp setup_new_device(config, pid_or_process_name, _file_name) do
    %{ config | device_pid: pid_or_process_name, device: pid_or_process_name }
  end



  defp maybe_enable_color_logging(config) do
    %{ config | use_ansi_color?: config.user_wants_color? && use_ansi?(config.device) }
  end


  # TODO handle USR1 across all running Devices

  defp maybe_setup_signal_handler(options) do
    options
    |> maybe_kill_existing_handler()
    |> maybe_add_new_handler()
  end



  defp maybe_kill_existing_handler(options) do
    SignalHandler.kill()
    options
  end



  defp maybe_add_new_handler(options = %{ device: name }) when is_binary(name) do
    if name = options.pid_file_name do
      File.write!(name, :os.getpid() |> to_string)
    end
    SignalHandler.start(options.name)
    options
  end

  defp maybe_add_new_handler(options) do
    options
  end



  # TODO: check this is legit... (can't use the :io.columns trick)
  defp use_ansi?(:user),            do: true
  defp use_ansi?(:standard_output), do: true
  defp use_ansi?(:standard_error),  do: true
  defp use_ansi?(_),                do: false



  defp open_log_file(name) do
    { :ok, pid } = File.open(name, [ :append, { :delayed_write, 2048, 500 }] )
    pid
  end
end

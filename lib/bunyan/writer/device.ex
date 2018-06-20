defmodule Bunyan.Writer.Device do

  @moduledoc """
  Write log messages to an IO device. We operate as a separate process
  to allow the rest to continue asynchronously.
  """

  # TODO update to store device

  use GenServer
  alias __MODULE__.{ Impl, State }


  @type name :: atom()   | pid()
  @type t    :: binary() | name()

  @doc """
  Update the configuration parameters associated with this device. Some
  configuration changes (such as compile-time log level) will have no effect.

  The first parameter is the name associated with this device.
  """

  @spec update_configuration(name :: atom(), new_config :: keyword()) :: any()

  def update_configuration(name \\ __MODULE__, new_config) do
    GenServer.call(name, { :update_configuration, new_config })
  end

  @doc """
  Change the device associated with this instance of the device writer. You can
  pass either the name of an IO handler process (typically `:user`,
  `:standard_output`, or `standard_error`), the PID of an IO device (often the
  value returned by `File.open`), or a string containing a file name.


  If the new device is given as a string, it is opened (in append mode).
  Otherwise it is assumed to be an atom naming an IO handler (such as
  `:standard_input` or `:user`.)

  Assuming the new device can be opened, we close the old one (but only is we'd
  previously opened it) and then replace it with the new one.

  You probably want to pass any file names using absolute paths.

  ~~~ elixir
  Bunyan.Writer.Device.set_log_device(:my_logger, :standard_error)
  Bunyan.Writer.Device.set_log_device(:app_errors, "/myapp/log/error_log")
  ~~~

  ### Notes

  * If the output is to a named file, then this process will look for
    SIGHUP signals. When recieved, the log file will be closed and
    reopened. This is meant to facilitate interoperation with tools such
    as logrotate.

  * If you have just one Device writer and don't give it a name, it will be
    called Bunyan.Writer.Device. With more than one Device writer, you must give
    each unique names in the config using the `name:` option.

  """

  @spec set_log_device(name :: name, device :: t) :: any()

  def set_log_device(name, device) do
    GenServer.call(name, { :set_log_device, device })
  end

  @doc """
  Close and then reopen the log file. This allows utilities such as logrotate to
  rename old files without us appending to them.

  This is passed the name or pid of the device to bounce.
  """
  @spec bounce_log_file(name :: name) :: :ok
  def bounce_log_file(name) when is_atom(name) or is_pid(name) do
    GenServer.call(name, { :bounce_log_file })
  end

  @doc false
  def start_link(options) do
    name    = Keyword.get(options, :name, __MODULE__)
    options = Keyword.put(options, :name, name)
    GenServer.start_link(__MODULE__, options, name: name)
  end

  @doc false
  def init(options) do
    { :ok, State.from_options(options) }
  end

  @doc false
  def handle_cast({ :log_message, msg}, options) do
    Impl.write_to_device(options, msg)
    { :noreply, options }
  end

  def handle_cast(x, options) do
    raise inspect handle_cast: x
  end
  @doc false
  def handle_call({ :set_log_device, device }, _, options) do
    flush_pending()

    options = Impl.set_log_device(options, device)
    { :reply, :ok, options }
  end

  @doc false
  def handle_call({ :update_configuration, new_config }, _, config) do
    flush_pending()
    new_config = State.from_options(new_config, config)
    { :reply, :ok,  new_config }
  end

  @doc false
  def handle_call({ :bounce_log_file }, _, config ) do
    { :reply, :ok, Impl.bounce_log_file(config) }
  end

  def terminate(_, options) do
    IO.inspect :terminating
    Impl.close_log_device(options)
  end


  defp flush_pending() do
    # IO.inspect queue_length: Process.info(self(), :message_queue_len)
  end
end

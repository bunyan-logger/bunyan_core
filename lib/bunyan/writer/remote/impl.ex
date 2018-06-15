defmodule Bunyan.Writers.Remote.Impl do

  alias Bunyan.Writers.Remote.State

  @valid_options [
    :send_to,        # name of the remote logger process
    :min_log_level,  # only send >= this
  ]

  def parse_options(options) do
    check_known_options(Keyword.keys(options) -- @valid_options)
    %State{}
    |> extract_send_to(options[:send_to])
    |> extract_min_log_level(options[:min_log_level])
  end



  defp check_known_options([]), do: nil
  defp check_known_options(unknown) do
    raise """

    Invalid option(s) passed to Bunyan.Writers.Remote: #{Enum.join(unknown, ", ")}

    Valid options are: #{Enum.join(@valid_options, ".")}

    """
  end

  ####

  defp extract_send_to(_result, nil) do
    raise """

    The `sent_to:` option is required when you use a Bunyan.Writers.Remote

    """
  end

  defp extract_send_to(result, name) do
    case Process.whereis(name) do
    nil ->
      remote_logger_not_found(name)
    pid ->
      %{ result | target_process_name: name, target_process_pid: pid }
    end
  end


  ####

  defp extract_min_log_level(result, nil) do
    result
  end

  defp extract_min_log_level(result, level) do
    %{ result | min_log_level: Bunyan.Level.of(level) }
  end

  defp remote_logger_not_found(name) do
    raise """

    Cannot find a remote logger named #{inspect name}.

    """
  end
end

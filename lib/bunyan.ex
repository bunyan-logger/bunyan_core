defmodule Bunyan do

  alias Bunyan.Shared.Level

  defmacro debug(msg_or_fun, extra \\ nil), do: maybe_generate(:debug, msg_or_fun, extra)
  defmacro  info(msg_or_fun, extra \\ nil), do: maybe_generate(:info,  msg_or_fun, extra)
  defmacro  warn(msg_or_fun, extra \\ nil), do: maybe_generate(:warn,  msg_or_fun, extra)
  defmacro error(msg_or_fun, extra \\ nil), do: maybe_generate(:error, msg_or_fun, extra)



  # yes, this breaks the encapsulation of the API config, but I can't
  # see another way to do this at compile time

  def compile_time_log_level() do
    with sources when is_list(sources) <- Application.get_env(:bunyan, :sources),
         api     when is_list(api)     <- sources[Bunyan.Source.Api],
         level                         =  api[:compile_time_log_level]
    do
      level
    else
      _ -> :debug
    end
  end

  def compile_time_log_level_number() do
    Level.of(compile_time_log_level())
  end

  # def runtime_log_level() do
  #   Application.get_env(:bunyan, :runtime_log_level)
  # end

  # def runtime_log_level_number() do
  #   Level.of(runtime_log_level())
  # end


  # def set_runtime_level(level) when level in [ :debug, :info, :warn, :error ] do
  #   Application.put_env(:bunyan, :runtime_log_level, Level.of(level))
  # end

  defp maybe_generate(level, msg_or_fun, extra) do

    if compile_time_level_not_less_than?(level) do
      quote do
        Bunyan.Source.Api.unquote(level)(unquote(msg_or_fun), unquote(extra))
      end
    else
      quote do
        _avoid_warning_about_unused_variables = fn -> { unquote(msg_or_fun), unquote(extra) } end
      end
    end
  end

  defp compile_time_level_not_less_than?(target) do
    compile_time_log_level_number() <= Level.of(target)
  end
end

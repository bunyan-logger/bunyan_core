defmodule Test.Bunyan.Writers.Device.WriteToFile do

  # Despite the name, all this really tests is that the log file is
  # reopened when we send a hup to the device writer

  use ExUnit.Case

  require Bunyan

  @logfile  "./test_log_file"
  @pidfile  "./test_pid"

  @device Bunyan.Writer.Device


  @config  [
          device:             @logfile,
          pid_file_name:      @pidfile,
          runtime_log_level:  :debug,
          use_ansi_color?:    false,
          main_format_string: "$time [$level] $message_first_line",
          additional_format_string: "$message_rest\n$extra",
        ]


  test "can log to a file" do
    File.rm(@logfile)
    File.rm(@pidfile)

    Bunyan.Writer.Device.update_configuration(@device, @config)


    Bunyan.error "one"
    Bunyan.error "two"
    Bunyan.error "three"

    # wait for the casts to be processed
    :timer.sleep(10)

    # this forces the file to be closed
    Bunyan.Writer.Device.set_log_device(@device, :user)

    f1 = File.read!(@logfile)
    assert f1 =~ ~r/one\n.*two\n.*three/
  end
end

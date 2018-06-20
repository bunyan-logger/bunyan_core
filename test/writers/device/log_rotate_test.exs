defmodule Test.Bunyan.Writers.Device.LogRotate do

  # Despite the name, all this really tests is that the log file is
  # reopened when we send a hup to the device writer

  use ExUnit.Case

  alias Bunyan.Writer.Device

  require Bunyan

  @logfile     "./test_log_file"
  @old_logfile "./test_log_file_old"
  @pidfile    "./test_pid"

  @device Bunyan.Writer.Device


  @config  [

          device:             @logfile,

          pid_file_name:      @pidfile,

          runtime_log_level:  :debug,

          main_format_string:       "$time [$level] $message_first_line",
          additional_format_string: "$message_rest\n$extra",

          use_ansi_color?:   false
        ]


  test "writes a pid file when the output device is a file" do
    File.rm(@pidfile)

    Bunyan.Writer.Device.update_configuration(@device, @config)

    assert { :ok, pid } = File.read(@pidfile)
    assert String.to_integer(pid) == :os.getpid |> List.to_integer()
  end

  test "reopens log file when hup sent" do
    File.rm(@logfile)
    File.rm(@old_logfile)
    File.rm(@pidfile)

    Bunyan.Writer.Device.update_configuration(@device, @config)

    Bunyan.error "one"

    File.rename(@logfile, @old_logfile)

    # we're still logging to the original file, but under its new name
    Bunyan.error "two"

    give_casts_a_chance_to_flush()

    # Now reopen
    System.cmd  "kill", [ "-usr1", :os.getpid() |> to_string ]


    Bunyan.error "three"

    # switch the log files back to close the disk log
    give_casts_a_chance_to_flush()

    Device.set_log_device(Device, :user)

    f1 = File.read!(@old_logfile)
    f2 = File.read!(@logfile)

    assert f1 =~ ~r/one.*\n.*two/
    assert !(f1 =~ ~r/three/)
    assert f2 =~ ~r/three/
  end

  defp give_casts_a_chance_to_flush() do
    :timer.sleep(10)
  end
end

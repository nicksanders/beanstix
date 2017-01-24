defmodule BeanstixStatsTest do
  use ExUnit.Case

  setup context do
    Beanstix.TestHelpers.setup_connection(context)
  end

  @tag no_setup: true
  test "stats parse" do
    stats = File.read!("test/files/stats.txt")
    |> Beanstix.Stats.parse()

    assert stats["rusage-utime"] == 0.004
    assert stats["current-jobs-urgent"] == 4
    assert stats["id"] == "33ecd66987a51631"
  end

  test "stats-job", %{pid: pid, tube: tube} do
    data = "1"
    assert {:ok, job_id} = Beanstix.command(pid, {:put, data})
    assert {:ok, data} = Beanstix.command(pid, {:stats_job, job_id})
    assert data["tube"] == tube
    assert data["state"] == "ready"
    assert data["delay"] == 0
    assert {:ok, :deleted} = Beanstix.command(pid, {:delete, job_id})
  end

  test "stats-tube", %{pid: pid, tube: tube} do
    data = "1"
    assert {:ok, job_id} = Beanstix.command(pid, {:put, data})
    assert {:ok, data} = Beanstix.command(pid, {:stats_tube, tube})
    assert data["name"] == tube
    assert data["current-jobs-ready"] == 1
    assert {:ok, :deleted} = Beanstix.command(pid, {:delete, job_id})
    assert {:ok, data} = Beanstix.command(pid, {:stats_tube, tube})
    assert data["current-jobs-ready"] == 0
  end

  test "stats", %{pid: pid} do
    assert {:ok, data} = Beanstix.command(pid, :stats)
    assert %{"current-jobs-urgent" => _x} = data
  end

end

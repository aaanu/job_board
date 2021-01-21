require 'minitest/autorun'
require_relative 'index'

# Common test data version: 5.0.0 7dfb96c
class IndexTest < Minitest::Test
  def test_job_board_process
    job_board = JobBoard.new
    assert_equal job_board.jobs[0].title, "Lead Chef"
    assert_equal job_board.jobs[0].to_s, "Title: Lead Chef, Organization: Chipotle, Location: Denver, CO, Pay: 10-15"
  end

  def test_job_board_sort_by_title
    job_board = JobBoard.new
    sorted_jobs = job_board.sort_by_title
    assert_equal sorted_jobs[0].to_s, "Title: Assistant to the Regional Manager, Organization: IBM, Location: Scranton, PA, Pay: 10-15"
    assert_equal sorted_jobs[1].to_s, "Title: Associate Tattoo Artist, Organization: Tit 4 Tat, Location: Brooklyn, NY, Pay: 250-275"
    assert_equal sorted_jobs[2].to_s, "Title: Lead Chef, Organization: Chipotle, Location: Denver, CO, Pay: 10-15"
  end

  def test_job_board_get_ny_jobs
    job_board = JobBoard.new
    ny_jobs = job_board.get_ny_jobs
    assert_equal ny_jobs[0].to_s, "Title: Associate Tattoo Artist, Organization: Tit 4 Tat, Location: Brooklyn, NY, Pay: 250-275"
    assert_equal ny_jobs[1].to_s, "Title: Lead Guitarist, Organization: Philharmonic, Location: Woodstock, NY, Pay: 100-200"
    assert_equal ny_jobs[2].to_s, "Title: Manager of Fun, Organization: IBM, Location: Albany, NY, Pay: 30-40"
  end

  def test_job_board_fast_state_lookup
    slow_job_board = JobBoard.new
    fast_job_board = JobBoard_FastStateLookup.new

    slow_start = Time.now
    slow_job = slow_job_board.find_by_title("Lead Guitarist")
    slow_finish = Time.now
    slow_diff = slow_finish - slow_start
    assert_equal slow_job.to_s, "Title: Lead Guitarist, Organization: Philharmonic, Location: Woodstock, NY, Pay: 100-200"

    fast_start = Time.now
    fast_job = fast_job_board.find_by_title("Lead Guitarist")
    fast_finish = Time.now
    fast_diff = fast_finish - fast_start
    assert_equal fast_job.to_s, "Title: Lead Guitarist, Organization: Philharmonic, Location: Woodstock, NY, Pay: 100-200"

    assert fast_diff < slow_diff
  end

  def test_job_board_new_input
    job_board = JobBoard_NewInput.new
    assert_equal job_board.jobs.length, 9
    assert_equal job_board.jobs["State Park Ranger"].to_s, "Title: State Park Ranger, Organization: Adirondack Park Agency, Location: Ray Brook, NY, Pay: 40-50"

    sorted = job_board.sort_by_title
    assert_equal sorted.values[0].to_s, "Title: Assistant to the Regional Manager, Organization: IBM, Location: Scranton, PA, Pay: 10-15"
    assert_equal sorted.values[1].to_s, "Title: Associate Tattoo Artist, Organization: Tit 4 Tat, Location: Brooklyn, NY, Pay: 250-275"

    ny_jobs = job_board.get_ny_jobs
    assert_equal ny_jobs.values[0].to_s, "Title: Associate Tattoo Artist, Organization: Tit 4 Tat, Location: Brooklyn, NY, Pay: 250-275"
    assert_equal ny_jobs.values[1].to_s, "Title: Lead Guitarist, Organization: Philharmonic, Location: Woodstock, NY, Pay: 100-200"
    assert_equal ny_jobs.values[3].to_s, "Title: State Park Ranger, Organization: Adirondack Park Agency, Location: Ray Brook, NY, Pay: 40-50"
  end

  def test_job_board_find_keyword
    job_board = JobBoard_NewInput.new
    assert_equal job_board.jobs.length, 9
    found = job_board.find_keyword("Lead")

    assert_equal found.length, 3
    assert_equal found.values[0].to_s, "Title: Lead Cephalopod Caretaker, Organization: Deep Adventures, Location: Atlantis, Oceania, Pay: 10-15"
    assert_equal found.values[1].to_s, "Title: Lead Chef, Organization: Chipotle, Location: Denver, CO, Pay: 10-15"
    assert_equal found.values[2].to_s, "Title: Lead Guitarist, Organization: Philharmonic, Location: Woodstock, NY, Pay: 100-200"
  end
end
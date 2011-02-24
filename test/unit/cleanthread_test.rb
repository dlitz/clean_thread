require File.expand_path "../../test_helper", __FILE__

require 'hospitalportal/cleanthread'

class CleanThreadTest < Test::Unit::TestCase
  def test_allow_multple_finish
    t = HospitalPortal::CleanThread.new do |t|
      loop do
        t.check_finishing
      end
    end
    t.start
    t.finish
    assert_nothing_raised do
      t.finish
    end
  end

  def test_allow_multple_finish_with_first_nowait
    t = HospitalPortal::CleanThread.new do |t|
      loop do
        t.check_finishing
      end
    end
    t.start
    t.finish(:nowait=>true)
    sleep 0.1 while t.alive?
    assert_nothing_raised do
      t.finish
    end
  end

  def test_alive_should_not_raise_error_if_thread_not_yet_started
    t = HospitalPortal::CleanThread.new { }
    assert_nothing_raised do
      assert !t.alive?
    end
  end
end

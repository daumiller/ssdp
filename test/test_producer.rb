require 'ssdp'
require 'minitest/autorun'
require 'minitest/pride'

class TestProducer < MiniTest::Unit::TestCase
  def test_running_is_accurate
    subject = SSDP::Producer.new :notifier => false
    subject.add_service 'test:minitest', 'telnet://localhost'
    assert_equal false, subject.running?
    subject.start
    assert_equal true, subject.running?
    subject.stop
    assert_equal false, subject.running?
  end

  def test_service_is_searchable
    subject = SSDP::Producer.new
    subject.add_service 'test:minitest', 'gopher://localhost'
    subject.start

    consumer = SSDP::Consumer.new :first_only => true, :service => 'test:minitest', :timeout => 2
    result = consumer.search
    assert result
    assert_equal "uuid:#{subject.uuid}", result[:params]['USN']

    subject.stop
  end

  def test_services_can_be_modified
    subject = SSDP::Producer.new
    subject.start

    consumer = SSDP::Consumer.new :first_only => true, :timeout => 2
    result = consumer.search :service => 'test:minitest_alpha'
    assert_nil result

    subject.add_service 'test:minitest_zero', 'ftp://ftp.cdrom.com'
    result = consumer.search :service => 'test:minitest_zero'
    assert result
    assert_equal "uuid:#{subject.uuid}", result[:params]['USN']

    subject.remove_service 'test:minitest_zero'
    result = consumer.search :service => 'test:minitest_zero'
    assert_nil result

    subject.add_service 'test:minitest_one', '...'
    subject.add_service 'test:minitest_two', '...'
    result_one = consumer.search :service => 'test:minitest_one'
    result_two = consumer.search :service => 'test:minitest_two'
    assert result_one
    assert result_two
    assert_equal "uuid:#{subject.uuid}", result_two[:params]['USN']
    assert_equal "uuid:#{subject.uuid}", result_one[:params]['USN']
    subject.stop
  end

  def test_start_and_stop_work
    subject = SSDP::Producer.new :notifier => false
    subject.add_service 'test:minitest:start_stop', 'about:blank'

    consumer = SSDP::Consumer.new :first_only => true, :timeout => 2
    result = consumer.search :service => 'test:minitest:start_stop'
    assert_nil result

    subject.start
    result = consumer.search :service => 'test:minitest:start_stop'
    assert result
    assert_equal "uuid:#{subject.uuid}", result[:params]['USN']

    subject.stop
    result = consumer.search :service => 'test:minitest:start_stop'
    assert_nil result
  end

  def test_uuid_can_be_set
    subject = SSDP::Producer.new :notifier => false
    subject.add_service 'test:minitest:uuid', '...'
    subject.uuid = 'test_uuid_can_be_set'
    subject.start

    consumer = SSDP::Consumer.new :first_only => true, :timeout => 2
    result = consumer.search :service => 'test:minitest:uuid'
    assert result
    assert_equal 'uuid:test_uuid_can_be_set', result[:params]['USN']

    subject.stop
  end

  def test_additional_parameters_are_passed
    subject = SSDP::Producer.new
    subject.add_service 'test:minitest:test_additional_parameters_are_passed',
      { 'AL' => '...', 'LOCATION' => '...', 'AddlHeader' => 'test_additional_parameters_are_passed' }
    subject.start

    consumer = SSDP::Consumer.new :first_only => true, :timeout => 2
    result = consumer.search :service => 'test:minitest:test_additional_parameters_are_passed'
    assert result
    assert_equal '...', result[:params]['AL']
    assert_equal '...', result[:params]['LOCATION']
    assert_equal 'test_additional_parameters_are_passed', result[:params]['AddlHeader']

    subject.stop
  end

  def test_notifications_can_be_disabled
    seen_notifications = 0
    consumer = SSDP::Consumer.new
    consumer.start_watching_type('test:minitest:test_notifications_can_be_disabled') { |ssdp| seen_notifications += 1 }

    subject = SSDP::Producer.new :notifier => false, :interval => 1
    subject.start
    subject.add_service 'test:minitest:test_notifications_can_be_disabled', '...'
    sleep(3)

    subject.stop
    sleep(1)
    consumer.stop_watching_all

    assert_equal 0, seen_notifications
  end

  def test_notifications_work
    seen_alive, seen_byebye = 0, 0
    consumer = SSDP::Consumer.new
    consumer.start_watching_type('test:minitest:test_notifications_work') do |ssdp|
      seen_alive  += 1 if ssdp[:params]['NTS'] == 'ssdp:alive'
      seen_byebye += 1 if ssdp[:params]['NTS'] == 'ssdp:byebye'
    end

    subject = SSDP::Producer.new :notifier => true, :interval => 1
    subject.start
    subject.add_service 'test:minitest:test_notifications_work', '...'

    sleep(3)
    subject.stop
    sleep(1)
    consumer.stop_watching_all

    assert_equal 3, seen_alive
    assert_equal 1, seen_byebye
  end

  def test_notification_interval_works
    seen_alive, seen_byebye = 0, 0
    consumer = SSDP::Consumer.new
    consumer.start_watching_type('test:minitest:test_notification_interval_works') do |ssdp|
      seen_alive  += 1 if ssdp[:params]['NTS'] == 'ssdp:alive'
      seen_byebye += 1 if ssdp[:params]['NTS'] == 'ssdp:byebye'
    end

    subject = SSDP::Producer.new :notifier => true, :interval => 3
    subject.start
    subject.add_service 'test:minitest:test_notification_interval_works', '...'

    sleep(7)
    subject.stop
    sleep(1)
    consumer.stop_watching_all

    assert_equal 3, seen_alive
    assert_equal 1, seen_byebye
  end

  def test_respond_to_all_works
    subject = SSDP::Producer.new :notifier => false
    subject.add_service 'test:minitest:test_respond_to_all_works_one', 'i_am_become_test'
    subject.add_service 'test:minitest:test_respond_to_all_works_two', 'i_am_become_test'
    subject.start

    consumer = SSDP::Consumer.new :timeout => 2, :filter => proc { |x| x[:params]['AL'] == 'i_am_become_test' }
    results = consumer.search :service => 'ssdp:all'
    assert results
    assert_equal 2, results.count
    assert results[0][:params]['ST'].start_with? 'test:minitest:test_respond_to_all_works_'
    assert results[1][:params]['ST'].start_with? 'test:minitest:test_respond_to_all_works_'

    subject.stop
    subject = SSDP::Producer.new :notifier => false, :respond_to_all => false
    subject.add_service 'test:minitest:test_respond_to_all_works_one', 'i_am_become_test'
    subject.add_service 'test:minitest:test_respond_to_all_works_two', 'i_am_become_test'
    subject.start

    consumer = SSDP::Consumer.new :timeout => 2, :filter => proc { |x| x[:params]['AL'] == 'i_am_become_test' }
    results = consumer.search :service => 'ssdp:all'
    assert results
    assert_equal 0, results.count

    subject.stop
  end
end

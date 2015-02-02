require 'ssdp'
require 'minitest/autorun'
require 'minitest/pride'

class TestProducer < MiniTest::Unit::TestCase
  def test_running_is_accurate
    subject = SSDP::Producer.new :notifier => false
    subject.add_service 'test:minitest', 'telnet://localhost'
    assert_equal subject.running?, false
    subject.start
    assert_equal subject.running?, true
    subject.stop
    assert_equal subject.running?, false
  end

  def test_service_is_searchable
    subject = SSDP::Producer.new
    subject.add_service 'test:minitest', 'gopher://localhost'
    subject.start

    consumer = SSDP::Consumer.new :first_only => true, :service => 'test:minitest', :timeout => 2
    result = consumer.search
    assert result
    assert_equal result[:params]['USN'], "uuid:#{subject.uuid}"

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
    assert_equal result[:params]['USN'], "uuid:#{subject.uuid}"

    subject.remove_service 'test:minitest_zero'
    result = consumer.search :service => 'test:minitest_zero'
    assert_nil result

    subject.add_service 'test:minitest_one', '...'
    subject.add_service 'test:minitest_two', '...'
    result_one = consumer.search :service => 'test:minitest_one'
    result_two = consumer.search :service => 'test:minitest_two'
    assert result_one
    assert result_two
    assert_equal result_one[:params]['USN'], result_two[:params]['USN']
    assert_equal result_two[:params]['USN'], "uuid:#{subject.uuid}"
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
    assert_equal result[:params]['USN'], "uuid:#{subject.uuid}"

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
    assert_equal result[:params]['USN'], 'uuid:test_uuid_can_be_set'

    subject.stop
  end

  def test_additional_parameters
    subject = SSDP::Producer.new
    subject.add_service 'test:minitest:test_additional_parameters',
      { 'AL' => '...', 'LOCATION' => '...', 'AddlHeader' => 'test_additional_parameters' }
    subject.start

    consumer = SSDP::Consumer.new :first_only => true, :timeout => 2
    result = consumer.search :service => 'test:minitest:test_additional_parameters'
    assert result
    assert_equal result[:params]['AL'], '...'
    assert_equal result[:params]['LOCATION'], '...'
    assert_equal result[:params]['AddlHeader'], 'test_additional_parameters'

    subject.stop
  end
end

require 'ssdp'
require 'minitest/autorun'
require 'minitest/pride'

class TestConsumer < Minitest::Test
  def dedupe_helper(results, param)
    # some network configurations will result in duplicated broadcast packets...
    unique, lookup = [], {}
    results.each do |item|
      test_value = item[:params][param]
      if test_value.nil?
        unique.push(item) # nothing we can do
        next
      end
      next if lookup.key?(test_value)
      lookup[test_value] = true
      unique.push item
    end
    unique
  end

  def test_synchronous_search_works
    producer = SSDP::Producer.new :notifier => false
    producer.add_service 'test:minitest:test_synchronous_search_works', '...'
    producer.start

    subject = SSDP::Consumer.new :timeout => 2, :synchronous => true, :first_only => true
    result  = subject.search :service => 'test:minitest:test_synchronous_search_works'
    producer.stop

    assert result
    assert_equal '...', result[:params]['AL']
  end

  def test_asynchronous_search_works
    producer = SSDP::Producer.new :notifier => false
    producer.add_service 'test:minitest:test_asynchronous_search_works', '...'
    producer.start

    subject = SSDP::Consumer.new :timeout => 2, :synchronous => false, :first_only => true
    result = nil
    subject.search :service => 'test:minitest:test_asynchronous_search_works' do |thread_result|
      result = thread_result
    end
    sleep(2)
    producer.stop

    assert result
    assert_equal '...', result[:params]['AL']
  end

  def test_multiple_search_works
    producer_one = SSDP::Producer.new :notifier => false
    producer_one.add_service 'test:minitest:test_multiple_search_works', 'test_one'
    producer_one.start

    producer_two = SSDP::Producer.new :notifier => false
    producer_two.add_service 'test:minitest:test_multiple_search_works', 'test_two'
    producer_two.start

    subject = SSDP::Consumer.new :timeout => 2, :first_only => false
    results = subject.search :service => 'test:minitest:test_multiple_search_works'
    producer_one.stop
    producer_two.stop

    results = dedupe_helper(results, 'AL')

    assert results
    assert_equal 2, results.count
    assert results[0][:params]['AL'] == 'test_one' || results[1][:params]['AL'] == 'test_one'
    assert results[0][:params]['AL'] == 'test_two' || results[1][:params]['AL'] == 'test_two'
  end

  def test_filtered_single_search_works
    producer = SSDP::Producer.new :notifier => false, :respond_to_all => true
    producer.add_service 'test:minitest:test_filtered_single_search_works', 'gopher://test_filtered_single_search_works'
    producer.start

    subject = SSDP::Consumer.new :timeout => 2, :first_only => true
    result = subject.search :service => 'ssdp:all',
                            :filter => proc { |x| x[:params]['AL'] == 'gopher://test_filtered_single_search_works' }
    producer.stop
    assert result
    assert_equal 'gopher://test_filtered_single_search_works', result[:params]['AL']

    result = subject.search :service => 'ssdp:all',
                            :filter => proc { |x| x[:params]['AL'] == 'gopher://test_filtered_single_search_works' }
    assert_nil result
  end

  def test_filtered_multiple_search_works
    producer = SSDP::Producer.new :notifier => false, :respond_to_all => true
    producer.add_service 'test:minitest:test_filtered_multiple_search_works_one',   '...'
    producer.add_service 'test:minitest:test_filtered_multiple_search_works_two',   '***'
    producer.add_service 'test:minitest:test_filtered_multiple_search_works_three', '...'
    producer.start

    subject = SSDP::Consumer.new
    results = subject.search :timeout    => 2,
                             :first_only => false,
                             :service    => 'ssdp:all',
                             :filter     => proc { |x| x[:params]['AL'] == '...' }
    producer.stop

    results = dedupe_helper(results, 'ST')

    assert results
    assert_equal 2, results.count
    assert_equal '...', results[0][:params]['AL']
    assert_equal '...', results[1][:params]['AL']
  end

  def test_single_timeout_works
    subject = SSDP::Consumer.new :timeout => 1, :first_only => true, :service => 'test:minitest:test_single_timeout_works'
    began = Time.now
    result = subject.search
    elapsed = Time.now - began
    assert elapsed > 0.75 # these time checks can be removed,
    assert elapsed < 2.25 # if they become a problem
    assert_nil result
  end

  def test_multiple_timeout_works
    subject = SSDP::Consumer.new :timeout => 2, :first_only => false, :service => 'test:minitest:test_single_timeout_works'
    began = Time.now
    results = subject.search
    elapsed = Time.now - began
    assert elapsed > 1.75 # these time checks can be removed,
    assert elapsed < 2.25 # if they become a problem
    assert results
    assert_equal 0, results.count
  end

  def test_watching_works
    producer = SSDP::Producer.new :notifier => true, :interval => 1
    producer.add_service 'test:minitest:test_watching_works', '...'
    producer.start

    positive_test, negative_test = nil, nil
    subject = SSDP::Consumer.new
    subject.start_watching_type('test:minitest:test_watching_works') { |x| positive_test = x[:params]['LOCATION'] }
    subject.start_watching_type('test:minitest:test_watching_fails') { |x| negative_test = x[:params]['LOCATION'] }
    sleep(2)
    subject.stop_watching_all

    producer.stop
    assert_equal '...', positive_test
    assert_nil negative_test
  end

  def test_stop_watch_single_works
    count_a, count_b = 0, 0
    subject = SSDP::Consumer.new
    subject.start_watching_type('test:minitest:test_stop_watch_single_works_a') { |_| count_a += 1 }
    subject.start_watching_type('test:minitest:test_stop_watch_single_works_b') { |_| count_b += 1 }

    producer = SSDP::Producer.new :notifier => true, :interval => 1
    producer.add_service 'test:minitest:test_stop_watch_single_works_a', '...'
    producer.add_service 'test:minitest:test_stop_watch_single_works_b', '...'
    producer.start

    sleep(2)
    subject.stop_watching_type 'test:minitest:test_stop_watch_single_works_a'
    sleep(2)
    subject.stop_watching_type 'test:minitest:test_stop_watch_single_works_b'
    producer.stop

    assert count_a > 0
    assert count_b > 0
    assert count_b > count_a
  end

  def test_stop_watch_all_works
    count_a, count_b = 0, 0
    subject = SSDP::Consumer.new
    subject.start_watching_type('test:minitest:test_stop_watch_all_works_a') { |_| count_a += 1 }
    subject.start_watching_type('test:minitest:test_stop_watch_all_works_b') { |_| count_b += 1 }

    producer = SSDP::Producer.new :notifier => true, :interval => 1
    producer.add_service 'test:minitest:test_stop_watch_all_works_a', '...'
    producer.add_service 'test:minitest:test_stop_watch_all_works_b', '...'
    producer.start

    sleep(2)
    subject.stop_watching_all
    sleep(3)
    producer.stop

    assert count_a > 0
    assert count_a < 3
    assert_equal count_a, count_b
  end
end

require 'watir'

# fetches and saves weekend results into files
class WeekendResultsManager
  def initialize
    @riders = { Hamilton: [],  Vettel: [], Ricciardo: [], Bottas: [], Räikkönen: [], Verstappen: [], Alonso: [], Hulkenberg: [], Sainz: [],
                Magnussen: [], Gasly: [], Perez: [], Ocon: [], Leclerc: [], Vandoorne: [], Stroll: [], Ericsson: [], Hartley: [],
                Grosjean: [], Sirotkin: []}
    open_and_prepare_browser
  end

  def get_whole_weekend_results(weekend_index)
    get_results_from_trainings(weekend_index, 5, 7)
    get_results_from_qp(3)
    get_results_race_only
  end

  def get_results_from_trainings(weekend_index, from, to)
    select_weekend(weekend_index)
    get_free_practice_results(from, to)
    @riders
  end

  def get_results_upto_qp(weekend_index)
    select_weekend(weekend_index)
    get_free_practice_results(2, 4)
    get_qualify_results(0)
    @riders
  end

  def close_browser
    @browser.close
  end

  private
  def get_results_from_qp(from)
    get_qualify_results(from)
    @riders
  end

  def get_results_race_only
    get_race_results
    @riders
  end

  def open_and_prepare_browser
    @browser = Watir::Browser.new
    @browser.window.resize_to 1920, 1080
    @browser.window.move_to 0, 0
    @browser.goto('https://www.formula1.com/en/results.html/2018/races.html')
  end

  def select_weekend(weekend_index)
    @browser.elements(:css => 'main .ResultArchiveContainer .resultsarchive-filter-wrap')[2].elements(:css => 'li a')[weekend_index].click! || sleep(1)
  end

  def get_free_practice_results(from, to)
    iterate_through_data(from, to)
  end

  def get_qualify_results(from)
    iterate_through_data(from, from)
  end

  def get_race_results
    iterate_through_data(0, 0)
  end

  def iterate_through_data(from, to)
    puts @browser.element(:css => '.circuit-info').text_content if from == 5

    (from..to).each do |session|
      session = @browser.elements(:css => 'main .ResultArchiveContainer .resultsarchive-col-left li a')[session]
      unless session.exists?
        @riders.each do |rider, data|
          data.push(['',''])
        end
        next
      end
      print session.text_content

      session.click! || sleep(1)
      @browser.elements(:css => 'main .ResultArchiveContainer .resultsarchive-col-right table tbody tr').each do |row|
        print '.'

        rider_name = row.elements(:css => 'td')[3].text_content.split(' ')[1]

        rider_position = row.elements(:css => 'td')[1].text_content
        rider_position = '20' if rider_position == 'NC'

        # rider_gap = row.elements(:css => 'td')[6].text_content
        # rider_gap = row.elements(:css => 'td')[5].text_content if from == 3
        # rider_gap = '0.000' if (rider_gap.include?(':') && from != 3) || (rider_gap == '' && rider_position == '1')
        # rider_gap.tr!('+', ''); rider_gap.tr!('s', ''); rider_gap.tr!(':', '')
        # rider_gap = '99.999' if rider_gap.include?('lap') || rider_gap.include?('DNF') || (rider_gap == '' && rider_position != '1')

        # @riders[rider_name.to_sym].push([rider_position, rider_gap]) if @riders.include?(rider_name.to_sym)
        @riders[rider_name.to_sym].push([rider_position]) if @riders.include?(rider_name.to_sym)
      end
      puts ''
    end
  end
end

# WeekendResultsManager.new.get_whole_weekend_results(1)
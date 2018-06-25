require './weekend_results_manager'

class Formula1
  def initialize(round)
    @round = round
    @results_manager = WeekendResultsManager.new
  end

  def get_whole_weekend_results
    results = @results_manager.get_whole_weekend_results(@round)
    @results_manager.close_browser
    results.each do |rider, data|
      # File.open('output/' + rider.to_s + '.csv', 'a') { |f| f.write("fp3,fp2,fp1,qp,race,\n") } if @round == 1
      print rider[(0..6)].to_s +  "\t\t"
      data.each do |session|
        print session[0].to_s  + "\t" + session[1].to_s + "\t"
        File.open('output/' + rider.to_s + '.csv', 'a') { |f| f.write(session[0].to_s  + ',') }
      end
      File.open('output/' + rider.to_s + '.csv', 'a') { |f| f.write("\n") }
      puts ''
    end
  end

  def get_results_from_trainings
    Dir.foreach('output_weekend/') {|f| fn = File.join('output_weekend/', f); File.delete(fn) if f != '.' && f != '..'}
    # results = @results_manager.get_results_from_trainings(@round, 0, 2)
    results = @results_manager.get_results_from_trainings(@round, 5, 7)
    results.each do |rider, data|
      print rider[(0..6)].to_s +  "\t\t"
      data.each do |session|
        print session[0].to_s  + "\t"
        File.open('output_weekend/' + rider.to_s + '.csv', 'a') { |f| f.write(session[0].to_s  + ',') }
      end
      File.open('output_weekend/' + rider.to_s + '.csv', 'a') { |f| f.write("\n") }
      puts ''
    end
  end

  def get_results_upto_qp
    Dir.foreach('output_weekend/') {|f| fn = File.join('output_weekend/', f); File.delete(fn) if f != '.' && f != '..'}
    results = @results_manager.get_results_upto_qp(@round)
    results.each do |rider, data|
      print rider[(0..6)].to_s +  "\t\t"
      data.each do |session|
        print session[0].to_s  + "\t"
        File.open('output_weekend/' + rider.to_s + '.csv', 'a') { |f| f.write(session[0].to_s  + ',') }
      end
      File.open('output_weekend/' + rider.to_s + '.csv', 'a') { |f| f.write("\n") }
      puts ''
    end
  end
end

# (1..8).each do |i|
#   Formula1.new(i).get_whole_weekend_results
# end

Formula1.new(8).get_results_from_trainings

# Formula1.new(8).get_results_upto_qp
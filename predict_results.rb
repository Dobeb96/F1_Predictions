class PredictResults
  def initialize(compared_to)
    @compared = compared_to == :qp ? 3 : 4
    @session_names = %w(fp3 fp2 fp1 qp race)
    @riders, @riders_diffs, @riders_means, @riders_sessions, @riders_medians, @riders_deviation, @riders_weekend = {}, {}, {}, {}, {}, {}, {}
    get_weekend_data
    get_riders_weekend
    calc_difference(@compared)
    calc_mean
    calc_median
    calc_deviation
    choose_most_precise_sessions
  end

  private
  def get_weekend_data
    Dir.entries('output').each do |filename_ext|
      next if filename_ext == '.' || filename_ext == '..'

      filename = filename_ext[0...-4]
      @riders[filename], @riders_diffs[filename], @riders_means[filename] = [], [], []
      @riders_sessions[filename], @riders_medians[filename], @riders_deviation[filename] = [], [], []
      @riders_weekend[filename] = []

      File.open('output/' + filename_ext) do |infile|
        while (line = infile.gets)
          next if line[0] == 'f'
          @riders[filename].push(line.split(',')[0...-1])
        end
      end
    end
  end

  def get_riders_weekend
    Dir.entries('output_weekend').each do |filename_ext|
      next if filename_ext == '.' || filename_ext == '..'

      filename = filename_ext[0...-4]

      File.open('output_weekend/' + filename_ext) do |infile|
        line = ''
        while (l = infile.gets)
          line = l
        end
        @riders_weekend[filename].push(line.split(',')[0...-1])
      end
    end
  end

  def calc_difference(compared_to)
    @riders.each do |rider|
      # p rider[0]
      rider[1].each do |weekend|
        diffs = []
        (0...compared_to).each do |i|
          diffs.push(weekend[i].to_i - weekend[compared_to].to_i)
        end
        @riders_diffs[rider[0]].push(diffs)
      end
    end
    # p @riders_diffs
  end

  def calc_mean
    @riders_diffs.each do |rider|
      means = Array.new(rider[1].first.size, 0)
      rider[1].each_with_index do |weekend|
        weekend.each_with_index do |session, i|
          means[i] = means[i].to_i +  session
        end
      end
      means.map! do |mean|
        mean.to_f / rider[1].size.to_f
      end
      @riders_means[rider[0]].push(means)
    end
    # p @riders_means
  end

  def calc_median
    @riders_diffs.each do |rider|
      medians = Array.new(rider[1].first.size)
      medians.map! { [] }
      rider[1].each_with_index do |weekend|
        weekend.each_with_index do |session, i|
          medians[i].push(session)
        end
      end
      medians.map! { |median| median.sort }
      @riders_sessions[rider[0]].push(medians)
    end

    @riders_sessions.each do |all_sessions|
      @riders_medians[all_sessions[0]] = []
      all_sessions[1].first.each_with_index do |session, i|
        length = session.size
        @riders_medians[all_sessions[0]][i] = (session[(length - 1) / 2] + session[length / 2] ) / 2.0
      end
    end
    # p @riders_sessions
    # p @riders_medians
  end

  def calc_deviation
    @riders_sessions.each do |rider, sessions|
      sessions.first.each_with_index do |session, i|
        deviation_sum = 0
        session.each do |result|
          deviation_sum += (result.to_f - @riders_means[rider][0][i].to_f)**2
        end
        @riders_deviation[rider].push(Math.sqrt(deviation_sum.to_f / session.size.to_f))
      end
    end
    # puts @riders_deviation
  end

  def choose_most_precise_sessions
    @riders_deviation.each do |rider, deviations|
      min_deviation = deviations.sort.first * 2.0

      outputs = [0, 0, 0]
      deviations.each_with_index do |deviation, i|
        if deviation < min_deviation && deviation < 6.0

          if @riders_means[rider].first[i] >= 0 then cutout = @riders_means[rider].first[i] - deviation else cutout = @riders_means[rider].first[i] + deviation end
          to_be_deleted = []

          @riders_sessions[rider].first[i].each_with_index do |result, j|
            if @riders_means[rider].first[i] >= 0 then to_be_deleted.push(result) if result < cutout else to_be_deleted.push(result) if result >= cutout end
          end

          print rider[0..6] + "\t\t" + @session_names[i] + ' '

          outputs[0] = (@riders_sessions[rider].first[i].size - to_be_deleted.size).to_f / @riders_sessions[rider].first[i].size.to_f

          to_be_deleted.each do |to_delete|
            @riders_sessions[rider].first[i].delete(to_delete)
          end

          mean = 0
          @riders_sessions[rider].first[i].each do |results|
            mean += results
          end

          outputs[1] = mean.to_f / @riders_sessions[rider].first[i].size.to_f

          length = @riders_sessions[rider].first[i].size
          outputs[2] = @riders_sessions[rider].first[i][(length - 1) / 2] + @riders_sessions[rider].first[i][length / 2] / 2.0

          print ' at ' + @riders_deviation[rider][i].round(2).to_s + "\t"
          # percentage  mean  deviation
          outputs.each_with_index do |output, k|
            print ((output * 100).to_i.to_s + '%') if k == 0
            i = 4 if @compared == 6
            print @riders_weekend[rider].first[i].to_f.round(2).to_s + '=>' + (@riders_weekend[rider].first[i].to_f - output).round(2).to_s if k == 1 || k == 2
            print "\t\t"
          end
          puts ''
        end
      end
    end
  end
end

# Use :qp or :race
session = :qp
session = ARGV[0].to_sym unless ARGV[0].nil?
PredictResults.new(session)
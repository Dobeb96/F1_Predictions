# What is it?

A crawler (`weekend_results_manager.rb`, `formula1.rb`) as well as a simple program (`predict_results.rb`) that predicts the results from Formula 1's qualifications and races.

# Usage

First run `ruby formula1.rb 1 'full'` to save full weekend results from round 1 to `output` folder. Run other rounds (2, 3, etc.) to gain more precise information.

Then on a Formula 1 weekend run `ruby formula1.rb 1 'fp'` or `ruby formula1.rb 1 'qp'` to save results from free practice sessions (`fp`) or qualifications (`qp`) to folder `output_weekend`.

Now you are ready to run data from `output_weekend` against `output`. To do this just run `ruby predict_results.rb 'qp'` to get predictions for qualifications, or `ruby predict_results.rb 'race'` for race.

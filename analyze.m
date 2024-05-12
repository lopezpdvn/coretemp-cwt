
tz = "America/Los_Angeles"
temps_file = '~/Downloads/core_export.csv'
raw_temps = readtable(temps_file, setvartype(detectImportOptions(temps_file), {'heat_strain_index', 'heart_rate_bpm_'}, 'double'))

period_range_start = hours(24-1.5)
period_range_end = hours(24+1.5)


raw_temps_with_datetimes = raw_temps

irregular_temps = table2timetable(raw_temps_with_datetimes)

temps = retime(irregular_temps, 'regular', 'linear', TimeStep=minutes(5))

[wt, period, coi] = cwt(temps.core_temperature_F_, 'amor', hours(5/60), VoicesPerOctave=48, ExtendSignal=false)
xrec = icwt(wt, [], period, [period_range_start, period_range_end], SignalMean=mean(temps.core_temperature_F_))


halflen = floor(length(coi)/2)
[val, coi_start_index] = min(abs(coi(1:halflen) - period_range_start))
[val, coi_end_index] = min(abs(coi(halflen+1 : end) - period_range_end))
coi_end_index = coi_end_index + halflen

temps_trimmed = temps(coi_start_index:coi_end_index, :)
xrec_trimmed = xrec(:, coi_start_index:coi_end_index)

%cwt(temps.core_temperature_F_, 'amor', hours(5/60), VoicesPerOctave=48)

[pks, maxlocs] = findpeaks(xrec_trimmed)
[pks, minlocs] = findpeaks(-xrec_trimmed)
diff(maxlocs)*minutes(5) - minutes(1440)
diff(minlocs)*minutes(5) - minutes(1440)

% print out circadian nadir times
temps_trimmed.date_time_local(minlocs)

plot(temps.date_time_local, temps.core_temperature_F_);

hold on;
%rectangle(Position=[tt_trimmed.date_time_local(1), 100, hours(1), 2], FaceColor=[0.9 0.9 0.9], EdgeColor='none')
plot(temps_trimmed.date_time_local, xrec_trimmed, LineWidth=2);

% Plot vertical lines denoting area of certainty
plot([temps.date_time_local(coi_start_index) temps.date_time_local(coi_start_index)], [min(temps_trimmed.core_temperature_F_), max(temps_trimmed.core_temperature_F_)])
plot([temps.date_time_local(coi_end_index) temps.date_time_local(coi_end_index)], [min(temps_trimmed.core_temperature_F_), max(temps_trimmed.core_temperature_F_)])

sleep_bar_height = 0.1 % degrees
sleep_bar_y_offset = 97.5
sleep_Y = [sleep_bar_y_offset (sleep_bar_y_offset + sleep_bar_height) (sleep_bar_y_offset+sleep_bar_height) sleep_bar_y_offset]; 
x1 = (datetime(2021,8,1, 10, 0, 0, TimeZone=tz));
x2 = (datetime(2021,8,2, TimeZone=tz));
%ptch = fill([x1 x1 x2 x2], sleep_Y, [0 0 0], FaceAlpha=0.15, EdgeColor='none');
hold off;

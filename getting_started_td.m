% based on getting_started script
% semi functional - imaging cannot be completed in time domain as of
% 07/08/2024

%% Loading sample data
% Details of the breast phantoms used to collect the sample data
% are given in "Microwave Breast Imaging: experimental
% tumour phantoms for the evaluation of new breast cancer diagnosis
% systems", 2018 Biomed. Phys. Eng. Express 4 025036.
% The antenna locations, frequency points and scattered signals
% are given in the /data folder:
%   antenna_locations.csv: the antenna locations in metres;
%   frequencies.csv: the frequency points in Hertz;
%   channel_names.csv: the descriptions of the channels in the scattered data;
%   B0_P3_p000.csv: homogeneous breast phantom with an 11 mm diameter
%     tumour located at (15, 0, 35) mm.
%   B0_P5_p000.csv: homogeneous breast phantom with an 20 mm diameter
%     tumour located at (15, 0, 30) mm.
% For both phantoms, a second scan rotated by 36 degrees from the first
% was acquired for artefact removal:
% B0_P3_p036.csv and B0_P5_p036.csv respectively.

frequencies = dlmread('example_data/frequencies.csv');
antenna_locations = dlmread('example_data/antenna_locations.csv');
channel_names = dlmread('example_data/channel_names.csv');
times = [0:5e-12:2e-8]';

scan1 = dlmread('example_data/B0_P3_p000.csv');
scan2 = dlmread('example_data/B0_P3_p036.csv');

%% Plot the acquired scans.
figure(1)
%combine the scans into one data channel
data_channel1 = [scan1(:, 1), scan2(:, 1)];
% get the phase of each data in frequency
channel1_phase = unwrap(angle(data_channel1));

subplot(2, 1, 1);

% to get the datain the time domain we ise the merit inverse fourier
% function
data_channel1_td = merit.process.fd2td((data_channel1.*gausspulsemodfreq), frequencies, times);

data_channel1_tdr = merit.process.td2fd(data_channel1_td, times, frequencies);

%plot time against data

plot(times, [data_channel1_td(:,1)]);
xlabel('Time (s)');
ylabel('data');
legend('Original Scan', 'Rotated Scan');
title(sprintf('Channel (%d, %d) Magnitude', channel_names(1, :)))

%plot freqencies against phase

subplot(2, 1, 2);
plot(frequencies, channel1_phase(:,1));
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
legend('Original Scan', 'Rotated Scan');
title(sprintf('Channel (%d, %d) Phase', channel_names(1, :)));
%% Perform rotation subtraction
signals = scan1-scan2;
signals(:,2:end)=0;


%% Plot artefact removed: channel 1
figure(2)

%get the phase if the 'signals'
rotated_channel1_phase = unwrap(angle(signals(:, 1)));


%use merit inverst fourier transform to get time domain
signals_td = merit.process.fd2td(signals, frequencies, times);
%limit signals to just the first column
signals_td_lim = signals_td(:,1);


%plot time vs the previous data, and the new data with the artefact removed
subplot(2, 1, 1);
plot(times, [data_channel1_td, signals_td_lim]);
xlabel('time');
ylabel('data');
legend('Original Scan', 'Rotated Scan', 'Artefact removed');
title(sprintf('Channel (%d, %d) Magnitude—Artefact removed', channel_names(1, :)));

%plot the hase v frequency for artefact removed
subplot(2, 1, 2);
plot(frequencies, [channel1_phase, rotated_channel1_phase]);
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
legend('Original Scan', 'Rotated Scan', 'Artefact removed');
title(sprintf('Channel (%d, %d) Phase—Artefact removed', channel_names(1, :)));

%% Generate imaging domain and visualise
[points, axes_] = merit.domain.hemisphere(radius=7e-2, resolution=4e-3);

%% Calculate delays

%this doenst  work in time domain from here on, will still output someting
% but not correctly
% merit.get_delays returns a function that calculates the delay
%   to each point from every antenna.
delays = merit.beamform.get_delays(channel_names, antenna_locations, ...
  relative_permittivity=8);

%% Perform imaging
img = abs(merit.beamform(signals, frequencies, points, delays, ...
        merit.beamformers.DAS));

%% Convert to grid for image display
%grid_ = merit.domain.img2grid(img, points, axes_{:});

im_slice = merit.visualize.get_slice(img, points, axes_, z=35e-3);
figure(3)
imagesc(axes_{1:2}, im_slice);

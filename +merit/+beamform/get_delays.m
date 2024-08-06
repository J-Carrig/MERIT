function [calculate_time] = get_delays(channels, antennas, options)
  
arguments
  channels                                                                                                                          % list of channels
  antennas                                                                                                                          % list of antenna locations
  options.relative_permittivity {mustBeNumeric, mustBeScalarOrEmpty, mustBeGreaterThanOrEqual(options.relative_permittivity,1)}     % relative permittivity must be a nummeric scaler >= 1
end
  c_0 = 299792458;  % speed of light in a vacuum
  relative_permittivity = options.relative_permittivity;

  speed = c_0./sqrt(relative_permittivity); %speed relative to speed of light

  antennas = antennas'; % transpose antennas array
  
  function [time] = calculate_(points)


    % permute: lets say points is a 4 x 5 x 6 (4 rows, 5 columns, 6 pages) matrix
    % permute (points [2,3,1]) tells us that there are 4 columns, 5 pages
    % and 6 rows in the new points array
    

    points = permute(points, [2, 3, 1]);
    distances = sqrt(sum( (antennas - points).^2, 1) );

    time = - ( distances(:, channels(:, 1), :) + distances(:, channels(:, 2), :) ) / speed;
  end
  calculate_time = @calculate_;
end
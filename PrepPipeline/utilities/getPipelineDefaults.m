function defaults = getPipelineDefaults(signal, type)
% Returns the defaults for a given step in the standard level 2 pipeline
%
% Parameters:
%     signal       a structure compatible with EEGLAB EEG structure
%                   (must have .data and .srate fields
%     type         a string indicating type of defaults to return:
%                  boundary, resample, detrend, globaltrend, linenoise
%                  reference
%
% Output:
%     defaults     a structure with the parameters for the default types
%                  in the form of a structure that has fields
%                     value: default value
%                     classes:   classes that the parameter belongs to
%                     attributes:  attributes of the parameter
%                     description: description of parameter
%
    nyquist = round(signal.srate/2);
    topMultiple = floor(nyquist/60);
    lineFrequencies = (1:topMultiple)*60;
    switch lower(type)
       case 'boundary'
            defaults = struct('ignoreBoundaryEvents', ...
                getRules(false, {'logical'}, {}, ...
                ['If true and EEG has boundary events, some EEGLAB ' ...
                  ' functions such as resample, respect boundaries, ' ...
                  'leading to spurious discontinuities.']));
        case 'resample'
            defaults = struct( ...
               'resampleOff', ...
                   getRules(true, {'logical'}, {}, ...
                   'If true, resampling is not used.'), ...
               'resampleFrequency', ...
                  getRules(512, {'numeric'}, {'scalar', 'positive'}, ...
                  ['Frequency to resample at. If signal already has a ' ...
                  'lower sampling rate, no resampling is done.']), ...
               'lowPassFrequency', ...
                  getRules(0, {'numeric'}, {'scalar', 'nonnegative'}, ...
                  ['Frequency to low pass or 0 if not performed. '...
                  'The purpose of this low pass is to remove resampling ' ...
                  'artifacts.']));
        case 'globaltrend'
             defaults = struct( ...
               'globalTrendChannels', ...
                  getRules(1:size(signal.data, 1), {'numeric'}, ...
                   {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
                   'Vector of channel numbers of the channels for global detrending.'), ...
                'doLocal', ...
                   getRules(true, {'logical'}, {}, ...
                   'If true, do a local linear trend before the global.'), ...
                'localCutoff', ...
                   getRules(1/200, {'numeric'}, ...
                   {'positive', 'scalar', '<', signal.srate/2}, ...
                   'Frequency cutoff for long term local detrending.'), ...
                'localStepSize', ...
                   getRules(40,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Seconds for detrend window slide.'));
        case 'detrend'
             defaults = struct( ...
               'detrendChannels', ...
                  getRules(1:size(signal.data, 1), {'numeric'}, ...
                   {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
                   'Vector of channel numbers of the channels to detrend.'), ...
                'detrendType', ...
                   getRules('high pass', {'char'}, {}, ...
                   ['One of {''high pass'', ''linear'', ''none''}' ...
                    ' indicating detrending type.']), ...
                'detrendCutoff', ...
                   getRules(1, {'numeric'}, ...
                   {'positive', 'scalar', '<', signal.srate/2}, ...
                   'Frequency cutoff for detrending or high pass filtering.'), ...
                'detrendStepSize', ...
                   getRules(0.02,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Seconds for detrend window slide.')  ...
               );
         case 'linenoise'
             defaults = struct( ...
               'lineNoiseChannels', ...
                  getRules(1:size(signal.data, 1), {'numeric'}, ...
                   {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
                   'Vector of channel numbers of the channels to detrend.'), ...
                'Fs', ...
                   getRules(signal.srate, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Sampling rate of the signal in Hz.'), ...
                'lineFrequencies', ...
                  getRules(lineFrequencies, {'numeric'}, ...
                   {'row', 'positive'}, ...
                   'Vector of frequencies of the line noise peaks to remove.'), ...
                'p', ...
                   getRules(0.01,  ...
                   {'numeric'}, {'positive', 'scalar', '<', 1}, ...
                   'Significance cutoff level.'),  ...
                'fScanBandWidth', ...
                   getRules(2,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   ['Half of the width of the frequency band centered ' ...
                    'on each line frequency.']),  ...
                'taperBandWidth', ...
                   getRules(2,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Bandwidth in Hz for the tapers.'),  ...   
                'taperWindowSize', ...
                   getRules(4,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Taper sliding window length in seconds.'),  ...
                 'taperWindowStep', ...
                   getRules(1,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Taper sliding window step size in seconds. '),  ...
                 'tau', ...
                   getRules(100,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Window overlap smoothing factor.'),  ...
                 'pad', ...
                   getRules(0,  ...
                   {'numeric'}, {'integer', 'scalar'}, ...
                   ['Padding factor for FFTs (-1= no padding, 0 = pad ' ...
                   'to next power of 2, 1 = pad to power of two after, etc.).']),  ...   
                'fPassBand', ...
                   getRules([0 signal.srate/2], {'numeric'}, ...
                   {'nonnegative', 'row', 'size', [1, 2], '<=', signal.srate/2}, ...
                   'Frequency band used (default [0, Fs/2])'),  ...
                'maximumIterations', ...
                   getRules(10,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   ['Maximum number of times the cleaning process ' ...
                   'applied to remove line noise.']) ...
               );
         case 'reference'
             defaults = struct( ...
               'srate', ...
                   getRules(signal.srate, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Sampling rate of the signal in Hz.'), ...
               'samples', ...
                   getRules(size(signal.data, 2), {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Sampling rate of the signal in Hz.'), ...
               'robustDeviationThreshold', ...
                   getRules(5, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Z-score cutoff for robust channel deviation.'), ...
               'highFrequencyNoiseThreshold', ...
                   getRules(5, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Z-score cutoff for SNR (signal above 50 Hz).'), ...
                'correlationWindowSeconds', ...
                   getRules(1, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Correlation window size in seconds.'), ...
                'correlationThreshold', ...
                   getRules(0.4, {'numeric'}, ...
                   {'positive', 'scalar', '<=', 1}, ...
                   'Max correlation threshold for channel being bad in a window.'), ...
                'badTimeThreshold', ...
                   getRules(0.01, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   ['Threshold fraction of bad correlation windows '...
                   'for designating a cutoff fraction of bad corr windows.']), ...
                 'ransacOff', ...
                   getRules(false, {'logical'}, {}, ...
                   ['If true, ransac is not used for bad channel ' ...
                    '(useful for small headsets).']), ...
                'ransacSampleSize', ...
                   getRules(50, {'numeric'}, ...
                   {'positive', 'scalar', 'integer'}, ...
                   'Number of samples for computing ransac.'), ...
                'ransacChannelFraction', ...
                   getRules(0.25, {'numeric'}, ...
                   {'positive', 'scalar', '<=', 1}, ...
                   'Sampling rate of the signal in Hz.'), ...
                'ransacCorrelationThreshold', ...
                   getRules(0.75, {'numeric'}, ...
                   {'positive', 'scalar', '<=', 1}, ...
                   'Cutoff correlation for unpredictability by neighbors.'), ...
                'ransacUnbrokenTime', ...
                   getRules(0.4, {'numeric'}, ...
                   {'positive', 'scalar', '<=', 1}, ...
                   'Cutoff fraction of time channel can have poor ransac predictability.'), ...
                'ransacWindowSeconds', ...
                   getRules(5, {'numeric'}, ...
                   {'positive', 'scalar'}, ...
                   'Correlation window size in seconds for ransac.'), ...
                'referenceType', ...
                  getRules('robust', {'char'}, {}, ...
                   ['Type of reference: robust (default), average, specific, none, or none-nointerp.' ...
                    'None: no interpolation is performed.']), ...
                 'interpolationOrder', ...
                   getRules('post-reference', {'char'}, {}, ...
                   ['post-reference: bad channels are detected again and interpolated after referencing. ' ...
                   'pre-reference: bad channels detected before referencing and interpolated. ' ...
                   'none: no interpolation is performed.']), ...
                'meanEstimateType', ...
                   getRules('median', {'char'}, {}, ...
                    ['Method for initial mean estimate in robust reference: ' ...
                      'huber (default), median, mean, or none']), ...
               'referenceChannels', ...   
                  getRules(1:size(signal.data, 1), {'numeric'}, ...
                   {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
                   'Vector of channel numbers of the channels used for reference.'), ...
                'evaluationChannels', ...
                  getRules(1:size(signal.data, 1), {'numeric'}, ...
                   {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
                   'Vector of channel numbers of the channels to test for noisiness.'), ...
              'rereferencedChannels', ...
                  getRules(1:size(signal.data, 1), {'numeric'}, ...
                   {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
                   'Vector of channel numbers of the channels to rereference.'), ...
              'channelLocations', ...
                  getRules(getFieldIfExists(signal, 'chanlocs'), {'struct'}, ...
                   {'nonempty'}, ...
                   'Structure of channel locations.'), ...
               'channelInformation', ...
                  getRules(getFieldIfExists(signal, 'chaninfo'), ...
                  {'struct'}, {}, ...
                  'Channel information --- particularly nose direction.'), ...
               'maxReferenceIterations', ...
                   getRules(4,  ...
                   {'numeric'}, {'positive', 'scalar'}, ...
                   'Maximum number of referencing interations'), ...
                'keepFiltered', ...
                    getRules(false, {'logical'}, {}, ...
                    'If true, final output is filtered rather than unfiltered'), ...
                'reportingLevel', ...
                   getRules('verbose',  ...
                   {'char'}, {}, ...
                   'How much information to store about referencing') ...
                   );
        otherwise
    end
end

function s = getRules(default, classes, attributes, description)
% Construct the default structure
    s = struct('default', [], 'classes', [], ...
        'attributes', [], 'description', []);
    s.default = default;
    s.classes = classes;
    s.attributes = attributes;
    s.description = description;
end
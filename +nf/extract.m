%% Given an nf object, return data from certain traces at particular times.
%
%
% ARGUMENTS:
%        obj -- A neurofield output struct (a Matlab struct containing data
%               from a simulation).
%        traces -- comma separated string of traces e.g. 'Propagator.2.phi, Coupling.2.nu'
%        t -- can be a time e.g. 0.001 or a range [0.001 0.1]. If empty, returns all times.
%        nodes -- an array of node numbers that are requested e.g. [1 2 3]
%                 traces and nodes are optional
%
% OUTPUT:
%        data -- .
%        t2 -- .
%
% REQUIRES:
%           -- <description>
%           -- <description>
%
% REFERENCES:
%
% AUTHOR:
%     Romesh Abeysuriya (2012-03-22).
%
% USAGE:
%{
    %
    output = nf.extract(obj,traces,t,nodes)
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data, t2] = extract(obj, traces, t, nodes)
    % If no nodes are provided, output all nodes
    if ~isstruct(obj) || ~isfield(obj, 'data')
        error('The first argument to nf.extract must be a NeuroField object');
    end
    
    if nargin < 4 || isempty(nodes)
        nodes = obj.nodes{1}; 
    elseif ~all(ismember(nodes, obj.nodes{1}))
        error('You have requested a nonexistant node');
    end

    % If no time is provided, output all times
    if nargin < 3 || isempty(t) 
        start = 1;
        stop = length(obj.time);
    else
        % Check boundaries
        if length(t) > 1
            if t(1) > t(2)
                fprintf('Start time larger than stop time- reversing order\n');
                t = t([2, 1]);
            end

            if t(2) > obj.time(end)
                fprintf('End time out of bounds- adjusting %.1fs to %.1fs\n', t(2), obj.time(end));
                t(2) = obj.time(end);
            end
        end %length(t) > 1
        
        if t(1) < obj.time(1)
            fprintf('Start time out of bounds- adjusting %.1fs to %.1fs\n', t(1), obj.time(1));
            t(1) = obj.time(1);
        end

        % Find the start/stop times
        % These commands return an empty matrix if requested times are out of range
        start = find(obj.time <= t(1), 1, 'last');
        if length(t) == 2
            stop = find(obj.time >= t(end), 1, 'first');
        else
            stop = start;
        end
        
        if isempty(start) || isempty(stop)
            error('Could not find times');
        end
    end

    % If no traces are requested, output all traces
    if nargin < 2 || isempty(traces)
        outputs = 1:length(obj.fields);
    else
        traces = regexp(traces, ' *, *', 'split'); % Split traces into cell array
        outputs = [];
        for j = 1:length(traces)
            idx = find(strcmpi(traces{j}, obj.fields));
            if isempty(idx)
                error('Requested trace "%s" could not be found', traces{j});
            else
                outputs(end+1) = idx;
            end
        end
    end

    % And assemble the output
    data = zeros(stop-start+1, length(outputs));

    for j = 1:length(outputs)
        [~, node_index] = ismember(nodes, obj.nodes{j});
        data(:, j) = obj.data{outputs(j)}(start:stop, node_index);
    end
    t2 = obj.time(start:stop);

end %function extract()

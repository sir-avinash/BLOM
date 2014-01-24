function data = BLOM_ConvertVectorToStruct(all_names,vec,selector)
%
% data = BLOM_ConvertVectorToStruct(all_names,vec,selector)
% 
% Converts vector data to a struct using all_names cell array of names.
%
% Input:
%   all_names-  Names of all variables, field of struct generated by
%               BLOM_ExtractModel.
%   vec     -   Vector of data, the same length as all_names.
%   selector-   Vector the same size as vec. Selects which entry to fill if
%               multiple names are present in a single all_names element. 
%               If equals zero (default), all entries are used.
%   

% convention should be 1-d vectors and cell-strings are column oriented
if size(vec,2) > 1
    vec = vec';
end
if (nargin < 3)
    selector = zeros(size(vec));
elseif size(selector,2) > 1
    selector = selector';
end

if isstruct(all_names)
    % can also input all_names_struct with precomputed vectorization info
    terms_so_far = all_names.terms_so_far;
    all_fields = all_names.all_fields;
    vec_idx = all_names.vec_idx;
    base_name = all_fields{1};
    port_number = all_fields{2};
    time_index = all_fields{3};
else
    if size(all_names,2) > 1
        all_names = all_names';
    end
    % number of ';' is number of multiple names
    num_terms = cellfun(@length, strfind(all_names,';')) + 1;
    terms_so_far = [0; cumsum(num_terms)];
    all_fields = textscan([all_names{:}],'BL_%sOut%dt%dport%dvecIdx%dminor%d','Delimiter','.;');
    if (selector(1) == 0)
        % all names required
        base_name = all_fields{1};
        port_number = all_fields{2};
        time_index = all_fields{3};
        vec_idx = zeros(terms_so_far(end),1); % preallocate vec_idx
        vec_idx(terms_so_far(1:end-1)+1) = 1:length(all_names); % first of each
        multiterms = find(num_terms > 1); % multiples, should be fewer of these
        for i = 1:length(multiterms)
            vec_idx(terms_so_far(multiterms(i))+2 : ...
                terms_so_far(multiterms(i)+1)) = multiterms(i);
        end
    end
end

if (selector(1) ~= 0)
    % just a subset given by selector vector required
    base_name = all_fields{1}(terms_so_far(1:end-1) + selector);
    port_number = all_fields{2}(terms_so_far(1:end-1) + selector);
    time_index = all_fields{3}(terms_so_far(1:end-1) + selector);
    vec_idx = (1:length(vec))';
end

% populate the data structure one variable name at a time
% goal is to set each matrix of (time, port) data in a vectorized way
[sorted, index] = sort(base_name);
% First sort by names, then find last occurrence of each name
[names, I] = unique(sorted);
I = [0; I];
for i=1:length(names)
    % convert times and port #'s for this signal name into 1d indices
    time_indices_i = time_index(index(I(i)+1:I(i+1)));
    port_numbers_i = port_number(index(I(i)+1:I(i+1)));
    size_i = [max(time_indices_i), max(port_numbers_i)];
    inds_i = sub2ind(size_i, time_indices_i, port_numbers_i);
    data.(names{i}) = zeros(size_i); % preallocate - maybe this should be nan's?
    data.(names{i})(inds_i) = vec(vec_idx(index(I(i)+1:I(i+1))));
end

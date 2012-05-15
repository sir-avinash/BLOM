function [RunResults ResultsVec]= BLOM_RunModel(ModelSpec,options)
%
%  [RunResults ResultsVec]= BLOM_RunModel(ModelSpec,options)
%
%   Executes the simulink model and returns the recorded values.
%   NOTE: Changes base workspace variables. 
%
% Input:
%   ModelSpec -   Model structure generatated by BLOM_ExtractModel.
%   options   -   options created by BLOM_optset function.
%
% Output:
%   RunResults -    Structure with fields according to ModelSpec, holding
%                   the simulation results. 
%   ResultsVec -    Vector with the same results    

sim(ModelSpec.name,0:ModelSpec.dt:ModelSpec.dt*ModelSpec.horizon);

ResultsVec = zeros(length(ModelSpec.all_names),1);

% very ugly : everything is done in the base workspace
for i=1:length(ModelSpec.all_names)
    idx = strfind(ModelSpec.all_names{i},'.');
    if length(idx)~=2
        continue;
    end
    name = ModelSpec.all_names{i}(1:idx(1)-1);
    % look for the variable in the base workspace
    if (isempty(evalin('base',['who(''' name ''')'])))
        warning(['Var ' name ' not found in base workspace']);
        continue;
    end
    % Time index 
    time = str2double(ModelSpec.all_names{i}(idx(2)+2:end));
    % Variable index for vector variables
    port = str2double(ModelSpec.all_names{i}(idx(1)+4:idx(2)-1));
    
    % Take the variable from the base workspace
    ResultsVec(i) =  evalin('base',[ name '.signals.values(' num2str(time) ',' num2str(port) ')']) ; 
end

RunResults = BLOM_ConvertVectorToStruct(ModelSpec.all_names,ResultsVec);

%> @file BLOM_SetDataLogging.m
%> @brief sets data logging to on for all variables and labels them
%>
%> @param BLOM1system String for name of system.  BLOM1system must be open
%>
%======================================================================

function BLOM_SetDataLogging(BLOM1System)
    subsystems = find_system({BLOM1System});
    subsystems(1) = [];
    for k = 1:length(subsystems)
        blockType = get_param(subsystems{k}, 'BlockType');
        if ~(strcmp(blockType, 'Mux') || strcmp(blockType, 'Demux') ||  ...
                strcmp(blockType, 'Inport') || strcmp(blockType, 'From') || ...
                (strcmp(blockType, 'SubSystem') && isempty(get_param(subsystems{k}, 'ReferenceBlock'))))

            name = get_param(subsystems{k}, 'Name');
            portHandles = get_param(subsystems{k}, 'PortHandles');
            outports = portHandles.Outport;

            if length(outports) == 1
                set_param(outports, 'DataLogging', 'on');
                set_param(outports, 'DataLoggingName', name);
            else
                for k = 1:length(outports)
                    set_param(outports(k), 'DataLogging', 'on');
                    set_param(outports(k), 'DataLoggingName', [name num2str(k)]);
                end          
            end
            
        end    
    end
end
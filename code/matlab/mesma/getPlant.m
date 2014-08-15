function specie = getPlant(idx, species_library)
% get plant endmember of the MESMA run

% calculate accuracy/recall

i=size(idx, 2);
while i>=1
    specie = species_library{idx(i)};
    if  isempty(strfind(specie, 'road')) && ...
             isempty(strfind(specie, 'shaddow')) && ...
             isempty(strfind(specie, 'NULL'))
        break;
    end
    i= i-1;
end





end


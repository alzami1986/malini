function [vol, cfg] = ft_prepare_singleshell(cfg, mri)

% FT_PREPARE_SINGLESHELL is deprecated, please use FT_PREPARE_HEADMODEL and
% FT_PREPARE_MESH
%
% See also FT_PREPARE_HEADMODEL

% TODO the spheremesh option should be renamed consistently with other mesh generation cfgs
% TODO shape should contain pnt as subfield and not be equal to pnt (for consistency with other use of shape)

% Copyright (C) 2006-2012, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_prepare_singleshell.m 7188 2012-12-13 21:26:34Z roboos $

warning('FT_PREPARE_SINGLESHELL is deprecated, please use FT_PREPARE_HEADMODEL with cfg.method = ''singleshell'' instead.')

revision = '$Id: ft_prepare_singleshell.m 7188 2012-12-13 21:26:34Z roboos $';

% do the general setup of the function
ft_defaults
ft_preamble help
ft_preamble provenance
ft_preamble trackconfig
ft_preamble debug
ft_preamble loadvar mri

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'renamed', {'spheremesh', 'numvertices'});
cfg = ft_checkconfig(cfg, 'deprecated', 'mriunits');

% set the defaults
if ~isfield(cfg, 'smooth');        cfg.smooth = 5;          end % in voxels
if ~isfield(cfg, 'threshold'),     cfg.threshold = 0.5;     end % relative
if ~isfield(cfg, 'numvertices'),   cfg.numvertices = [];    end % approximate number of vertices in sphere

% the data is specified as input variable or input file
hasmri = exist('mri', 'var');

if hasmri
  vol.bnd = ft_prepare_mesh(cfg, mri);
else
  vol.bnd = ft_prepare_mesh(cfg);
end

vol.type = 'singleshell';

% ensure that the geometrical units are specified
vol = ft_convert_units(vol);

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble provenance
if hasmri
  ft_postamble previous mri
end
ft_postamble history vol


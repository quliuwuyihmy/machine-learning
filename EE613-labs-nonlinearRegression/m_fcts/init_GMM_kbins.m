function model = init_GMM_kbins(Data, model, nbSamples)
% Initialization of Gaussian Mixture Model (GMM) parameters by clustering 
% the data into equal bins based on the first variable (time steps).
%
% Writing code takes time. Polishing it and making it available to others takes longer! 
% If some parts of the code were useful for your research of for a better understanding 
% of the algorithms, please reward the authors by citing the related publications, 
% and consider making your own research available in this way.
%
% @article{Calinon15,
%   author="Calinon, S.",
%   title="A Tutorial on Task-Parameterized Movement Learning and Retrieval",
%   journal="Intelligent Service Robotics",
%   year="2015"
% }
%
% Copyright (c) 2015 Idiap Research Institute, http://idiap.ch/
% Written by Sylvain Calinon, http://calinon.ch/
% 
% This file is part of PbDlib, http://www.idiap.ch/software/pbdlib/
% 
% PbDlib is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
% 
% PbDlib is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PbDlib. If not, see <http://www.gnu.org/licenses/>.


diagRegularizationFactor = 1E-8; %Optional regularization term to avoid numerical instability
nbData = size(Data,2) / nbSamples;

%Delimit the cluster bins for the first demonstration
tSep = round(linspace(1, nbData, model.nbStates+1)); 

%Compute statistics for each bin
for i=1:model.nbStates
	id=[];
	for n=1:nbSamples
		id = [id (n-1)*nbData+[tSep(i):tSep(i+1)]];
	end
	model.Priors(i) = length(id);
	model.Mu(:,i) = mean(Data(:,id),2);
	model.Sigma(:,:,i) = cov(Data(:,id)') + eye(size(Data,1)) * diagRegularizationFactor;
end
model.Priors = model.Priors / sum(model.Priors);

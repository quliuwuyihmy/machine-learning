function demo_GPR01
% Gaussian process regression (GPR) 
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

addpath('./m_fcts/');


%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbVar = 3; %Dimension of datapoint (t,x1,x2)
nbData = 20; %Number of datapoints
nbDataRepro = 100; %Number of datapoints for reproduction
nbSamples = 1; %Number of demonstrations
p(1)=1E0; p(2)=1E1; p(3)=1E-2; %GPR parameters


%% Load handwriting data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
demos=[];
load('data/2Dletters/G.mat');
Data=[];
for n=1:nbSamples
	s(n).Data = spline(1:size(demos{n}.pos,2), demos{n}.pos, linspace(1,size(demos{n}.pos,2),nbData)); %Resampling
	tt = [1:nbData/2,3*nbData/4:nbData];  %Simulate missing data
	s(n).Data = [tt; s(n).Data(:,tt)];
	Data = [Data s(n).Data]; 
end

%GPR precomputation
xIn = Data(1,:);
xOut = Data(2:end,:);
M = pdist2(xIn', xIn');
K = p(1) * exp(-p(2)^-1 * M.^2);
invK = pinv(K + p(3) * eye(size(K))); 


%% Reproduction with GPR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xInHat = linspace(1,nbData,nbDataRepro);
Md = pdist2(xInHat', xIn');
Kd = p(1) * exp(-p(2)^-1 * Md.^2);
xOutHat = (Kd * invK * xOut')'; 

%Covariance computation
Mdd = pdist2(xInHat',xInHat');
Kdd = p(1) * exp(-p(2)^-1 * Mdd.^2);
S = Kdd - Kd * invK * Kd';
SigmaOut = zeros(nbVar-1,nbVar-1,nbData);
for t=1:nbDataRepro
	SigmaOut(:,:,t) = eye(nbVar-1) * S(t,t); 
end


%% Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position',[10 10 1300 600]);
%Plots 1D
for m=2:nbVar
	limAxes = [1, nbData, min(Data(m,:))-1E0, max(Data(m,:))+1E0];
	subplot(nbVar-1,2,(m-2)*2+1); hold on;
	patch([xInHat, xInHat(1,end:-1:1)], ...
		[xOutHat(m-1,:)+squeeze(SigmaOut(m-1,m-1,:).^.5)'*1E1, xOutHat(m-1,end:-1:1)-squeeze(SigmaOut(m-1,m-1,end:-1:1).^.5)'*1E1], ...
		[1 .8 .8],'edgecolor','none');
	plot(xInHat, xOutHat(m-1,:), '-','lineWidth',2,'color',[.8 0 0]);
	for n=1:nbSamples
		plot(s(n).Data(1,:), s(n).Data(m,:), '.','markersize',20,'color',[.2 .2 .2]);
	end
	set(gca,'xtick',[],'ytick',[]);
	xlabel('t','fontsize',18);
	ylabel(['x_' num2str(m-1)],'fontsize',18);
	axis(limAxes);
end
%Plot 2D
subplot(nbVar-1,2,[2:2:(nbVar-1)*2]); hold on;
plotGMM(xOutHat,SigmaOut*1E1,[1 .2 .2],.2);
plot(xOutHat(1,:), xOutHat(2,:), '-','lineWidth',2,'color',[.8 0 0]);
for n=1:nbSamples
	plot(s(n).Data(2,:), s(n).Data(3,:), '.','markersize',20,'color',[.2 .2 .2]); 
end
set(gca,'xtick',[],'ytick',[]); axis equal; axis square;
xlabel('x_1','fontsize',18);
ylabel('x_2','fontsize',18);

%print('-dpng','graphs/demo_GPR01.png');
pause;
close all;


function spm_DEM_qU(qU,pU)
% displays conditional estimates of states (qU)
% FORMAT spm_DEM_qU(qU,pU);
%
% qU.v{i}    - causal states (V{1} = y = predicted response)
% qU.x{i}    - hidden states
% qU.e{i}    - prediction error
% qU.C{N}    - conditional covariance - [causal states] for N samples
% qU.S{N}    - conditional covariance - [hidden states] for N samples
%
% pU         - optional input for known states
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_DEM_qU.m 4621 2012-01-13 11:12:40Z guillaume $
 
% unpack
%--------------------------------------------------------------------------
clf
V      = qU.v;
E      = qU.z;
try
    X  = qU.x;
end
try
    C  = qU.C;
    S  = qU.S;
end
try
    pV = pU.v;
    pX = pU.x;
end
 
% order of hierarchy
%--------------------------------------------------------------------------
try
    g = length(X) + 1;                           
    if isempty(X{end})
        g = g - 1;
    end
catch
    g = length(V);
end

% time-series specification
%--------------------------------------------------------------------------
N     = size(V{1},2);                            % length of data sequence
dt    = 1;                                       % time step
t     = [1:N]*dt;                                % time
 
% unpack conditional covariances
%--------------------------------------------------------------------------
ci    = spm_invNcdf(1 - 0.05);
s     = [];
c     = [];
try
    for i = 1:N
        c = [c abs(sqrt(diag(C{i})))];
        s = [s abs(sqrt(diag(S{i})))];
    end
end
 
% loop over levels
%--------------------------------------------------------------------------
for i = 1:g
 
    if N == 1
 
        % hidden causes and error - single observation
        %------------------------------------------------------------------
        subplot(g,2,2*i - 1)
        t = 1:size(V{i},1);
        plot(t,full(E{i}),'r:',t,full(V{i}))
        box off
 
 
        % conditional covariances
        %------------------------------------------------------------------
        if i > 1 && size(c,1)
            hold on
            j      = [1:size(V{i},1)];
            y      = ci*c(j,:);
            c(j,:) = [];
            fill([t fliplr(t)],[full(V{i} + y)' fliplr(full(V{i} - y)')],...
                 [1 1 1]*.8,'EdgeColor',[1 1 1]*.8)
            plot(t,full(E{i}),'r:',t,full(V{i}))
            hold off
        end
 
        % title and grid
        %------------------------------------------------------------------
        title('hidden causes','FontSize',16);
        axis square
        set(gca,'XLim',[t(1) t(end)])
        box off
 
    else
 
        % hidden causes and error - time series
        %------------------------------------------------------------------
        subplot(g,2,2*i - 1)
        try
            plot(t,pV{i},':k','linewidth',1)
        end
        hold on
        try
            plot(t,full(V{i}))
        end
        try
            plot(t,full(E{i}),'r:')
        end
        box off, hold off
        set(gca,'XLim',[t(1) t(end)])
        a   = axis;
 
        % conditional covariances
        %------------------------------------------------------------------
        if i > 1 && size(c,1)
            hold on
            j      = (1:size(V{i},1));
            y      = ci*c(j,:);
            c(j,:) = [];
            fill([t fliplr(t)],[full(V{i} + y) fliplr(full(V{i} - y))],...
                        [1 1 1]*.8,'EdgeColor',[1 1 1]*.8)
            try 
                plot(t,pV{i},':k','linewidth',1)
            end
            try
                plot(t,full(E{i}),'r:')
            end
            plot(t,full(V{i})),box off
            hold off
        end
 
        % title, action and true causes (if available)
        %------------------------------------------------------------------
        if i == 1
            title('prediction and error','FontSize',16);
        elseif length(V) < i
            title('no causes','FontSize',16);
        elseif ~size(V{i},1)
            title('no causes','FontSize',16);
        else
            title('hidden causes','FontSize',16);
            try
                hold on
                plot(t,pV{i},':k','linewidth',1),box off
            end
            hold off
        end
        xlabel('time','FontSize',14)
        axis square
        axis(a)
 
        % hidden states
        %------------------------------------------------------------------
        try
 
            subplot(g,2,2*i)
            try
                hold on
                plot(t,full(pX{i}),':k','linewidth',1),box off
            end
            hold off
            plot(t,full(X{i})),box off
            set(gca,'XLim',[t(1) t(end)])
            a   = axis;
            
            if ~isempty(s)
                hold on
                j      = [1:size(X{i},1)];
                y      = ci*s(j,:);
                s(j,:) = [];
                fill([t fliplr(t)],[full(X{i} + y) fliplr(full(X{i} - y))],...
                        [1 1 1]*.8,'EdgeColor',[1 1 1]*.8)
                try
                    plot(t,full(pX{i}),':k','linewidth',1),box off
                end
                plot(t,full(X{i})),box off
                hold off
            end
                      
            % title and grid
            %--------------------------------------------------------------
            title('hidden states','FontSize',16)
            xlabel('time','FontSize',14)
            axis square
            axis(a);
            
        catch
            delete(gca)
        end
    end
end
 
% plot action if specified
%--------------------------------------------------------------------------
if isfield(qU,'a')
    subplot(g,2,2*g)
    plot(t,full(qU.a{end}));
    str = 'action';
    try
        hold on
        plot(t,full(pU.v{2}),':b','Linewidth',2),box off
        str = 'perturbation and action';
    end
    hold off
    xlabel('time','Fontsize',14)
    title(str,'Fontsize',16)
    axis square
    set(gca,'XLim',[t(1) t(end)])
    box off
end
hold off
drawnow

classdef TBG < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        theta = 0;
        m=1;
        n=1;
        a0=1;
        c0=3;
        a;
        A;              % Superlattice lattice vector
        p;         % p(:,:,1) and p(:,:,2) are the coordinates lattice points on layer 1 and 2 respectively
        c;         % c(:,:,1), c(:,:,2) are atom coordinates on layer 1 and 2
        N;
    end
    
    methods
        function tbg = TBG(a0, c0, n, m)
            tbg.a0 = a0;
            tbg.c0 = c0;
            tbg.n = n;
            tbg.m = m;
            tbg.theta = acos((n^2+4*m*n+m^2)/(2*(n^2+n*m+m^2)))*sign(n-m);
            a1 = [1.5; -0.5*sqrt(3)] * a0;
            a2 = [1.5; 0.5*sqrt(3)] * a0;
            R1 = [cos(tbg.theta/2), -sin(tbg.theta/2); sin(tbg.theta/2), cos(tbg.theta/2)];
            R2 = [cos(tbg.theta/2), sin(tbg.theta/2); -sin(tbg.theta/2), cos(tbg.theta/2)];
            A1 = R1 * ( n*a1 + m*a2);
            A2 = R1 * (-m*a1 + (n+m)*a2);
            a11 = R1 * a1;
            a21 = R1 * a2;
            a12 = R2 * a1;
            a22 = R2 * a2;
            tbg.A = [A1, A2];
            tbg.a = [a1, a2];
            
            p1 = find_points(tbg, n, m, a11, a21);
            p2 = find_points(tbg, m, n, a12, a22);
            
            size(p1,1)
            size(p2,1)
            assert(size(p1,1) == n^2+m^2+n*m);
            assert(size(p2,1) == n^2+m^2+n*m);
            
            tbg.p(:,:,1) = p1;
            tbg.p(:,:,2) = p2;
            
            tbg.N = n^2+m^2+n*m;
            tbg.c(:,:,1) = [tbg.p(:,:,1) + 1/3 * ((a11 + a21)*ones(1,tbg.N))';tbg.p(:,:,1) - 1/3 * ((a11 + a21)*ones(1,tbg.N))'];
            tbg.c(:,:,2) = [tbg.p(:,:,2) + 1/3 * ((a12 + a22)*ones(1,tbg.N))';tbg.p(:,:,2) - 1/3 * ((a12 + a22)*ones(1,tbg.N))'];
            
            disp('Twisted bilayer graphene initialized');
            disp(['Twist angle: ',num2str(tbg.theta/pi*180),' degrees']);
            
        end
        
        % find all possible lattice coordinates in a superlattice. Basic
        % idea: In a TBG, the SUPERLATTICE BASE VECTORS corresponds to (n,
        % m) and (-m, n+m) in LAYER 1 (rotated counterclockwise for
        % theta/2). It corresponds to (m,n) and (-n, n+m) in LAYER 2
        % (rotated clockwise for theta/2). The purpose of this function is
        % to find out what possible combinations of (n',m') are inside the
        % region defined by the superlattice base vectors. The result
        % should contain exactly n^2+m^2+nm points. For LAYER 1, pass n, m
        % to this function and m, n for LAYER 2. a1 and a2 should be set to
        % the base vector of the corresponding layer.
        function points = find_points(tbg, p, q, a1, a2)
            % P and Q stores all possible points in lattice coordinates
            [P, Q] = meshgrid(-q:p, 0:(p+2*q));
            r = p^2 + q^2 + p*q;
            % The linear transformation transforms the permitted area into
            % a unit square
            P1 = ((p+q) * P + q * Q) ./ r;
            Q1 = (   -q * P + p * Q) ./ r;
            % Now rule out those points that are not in the unit square
            % after transformation
            In = (P1 >= 0) & (P1 < 1)...
            & (Q1 >= 0) & (Q1 < 1);
            % Convert the lattice coordinates back to real coordinates
            % using provided base vector
            points = P(In) * a1' + Q(In) * a2';
            disp('Complete');
%             figure;
%             axis equal tight;
%             scatter(P1(:),Q1(:));
%             figure;
%             axis equal tight;
%             scatter(P(In),Q(In));
%             figure;
%             axis equal tight;
%             scatter(points(:,1),points(:,2));
%             hold on
%             plot([0,a1(1)],[0,a1(2)]);
%             plot([0,a2(1)],[0,a2(2)]);
%             hold off
        end
        
        
        
        function plot(tbg)
            N = tbg.n+tbg.m;
            a = tbg.a0;
            th = tbg.theta;
            R1 = [cos(th/2), -sin(th/2); sin(th/2), cos(th/2)];
            R2 = [cos(th/2), sin(th/2); -sin(th/2), cos(th/2)];
            c1 = 1.5 * a;
            c2 = sqrt(3) / 2 * a;
            c3 = 0.5 * a;
            fh = figure;
            axis equal tight;
            hold on;
            for i=-max(tbg.n, tbg.m)-2:max(tbg.n, tbg.m)+2
                for j=-2:2*N
                    % Convert lattice coordinate to space coordinate
                    x = c1 * double(i + j);
                    y = c2 * double(j - i);
                    p1 = [x;y] + [-a; 0];
                    p2 = [x;y] + [-c3; c2];
                    p3 = [x;y] + [c3; c2];
                    p4 = [x;y] + [a; 0];
                    line1 = [R1*p1, R1*p2, R1*p3, R1*p4];
                    line2 = [R2*p1, R2*p2, R2*p3, R2*p4];
                    plot(line1(1,:), line1(2,:), 'k', line2(1,:), line2(2,:), 'k');
                end
            end
            
            t1 = tbg.A(:,1);
            t2 = tbg.A(:,2);          
            plot([0; t1(1)], [0; t1(2)], 'g', 'LineWidth', 1.5);
            plot([0; t2(1)], [0; t2(2)], 'g', 'LineWidth', 1.5);
            plot([t1(1); t1(1) + t2(1)], [t1(2); t1(2) + t2(2)], 'g', 'LineWidth', 1.5);
            plot([t2(1); t1(1) + t2(1)], [t2(2); t1(2) + t2(2)], 'g', 'LineWidth', 1.5);
            hold off
            figure
            axis equal tight
            hold on
            plot([0; t1(1)], [0; t1(2)], 'g', 'LineWidth', 1.5);
            plot([0; t2(1)], [0; t2(2)], 'g', 'LineWidth', 1.5);
            plot([t1(1); t1(1) + t2(1)], [t1(2); t1(2) + t2(2)], 'g', 'LineWidth', 1.5);
            plot([t2(1); t1(1) + t2(1)], [t2(2); t1(2) + t2(2)], 'g', 'LineWidth', 1.5);
            scatter(tbg.p(:,1,1), tbg.p(:,2,1),36, 'red');
            scatter(tbg.p(:,1,2), tbg.p(:,2,2),36, 'blue');
            hold off;
            figure
            axis equal tight
            hold on
            plot([0; t1(1)], [0; t1(2)], 'g', 'LineWidth', 1.5);
            plot([0; t2(1)], [0; t2(2)], 'g', 'LineWidth', 1.5);
            plot([t1(1); t1(1) + t2(1)], [t1(2); t1(2) + t2(2)], 'g', 'LineWidth', 1.5);
            plot([t2(1); t1(1) + t2(1)], [t2(2); t1(2) + t2(2)], 'g', 'LineWidth', 1.5);
            scatter3(tbg.c(:,1,1), tbg.c(:,2,1),zeros(tbg.N*2,1),36, 'red');
            scatter3(tbg.c(:,1,2), tbg.c(:,2,2),ones(tbg.N*2,1)*tbg.c0,36, 'blue');
            hold off;
            
        end
    end
    
end


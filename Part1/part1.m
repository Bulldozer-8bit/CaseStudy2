rng(105);
P0 = [5*rand(50,2); 5*rand(50,2) + [6 0]];
for r = 0.1:0.1:12.1
    G = make_disk(P0,r);
    stats4 = graph_stats(G);
    if stats4.diameter < Inf
        r_min = r;
        break;
    end
end

fprintf('>>> Calculated minimum connection radius r_min: %.1f\n', r_min);

k = round(stats4.edge_count/100);
fprintf('>>> Calculated ring graph parameter k: %d\n\n', k);

G1 = make_complete(100);
G2 = make_star(100);
G3 = make_ring(100,k);
G4 = G;

stats1 = graph_stats(G1);
stats2 = graph_stats(G2);
stats3 = graph_stats(G3);
stats4 = graph_stats(G4);

T1 = [stats1.edge_count, mean(stats1.degree), max(stats1.degree), stats1.diameter];
T2 = [stats2.edge_count, mean(stats2.degree), max(stats2.degree), stats2.diameter];
T3 = [stats3.edge_count, mean(stats3.degree), max(stats3.degree), stats3.diameter];
T4 = [stats4.edge_count, mean(stats4.degree), max(stats4.degree), stats4.diameter];

Results = [T1; T2; T3; T4];

disp('=== Comparison of Network Characteristics for Four Topologies ===');
GraphTypes = {'Complete_T1'; 'Star_T2'; 'Ring_T3'; 'Disk_T4'};
VarNames = {'EdgeCount', 'MeanDegree', 'MaxDegree', 'Diameter'};
ResultsTable = array2table(Results, 'RowNames', GraphTypes, 'VariableNames', VarNames);
disp(ResultsTable);

figure;
H = graph(G);
plot(H, 'XData', P0(:,1), 'YData', P0(:,2));
axis equal;
title('T4 Disk Network');

disp('=== Function Testing Module ===');

disp('1. Testing Complete Graph: make_complete(4)');
G_test = make_complete(4);
disp('  Adjacency Matrix:'); disp(G_test);
stats_test = graph_stats(G_test);
disp('  Graph Statistics:'); disp(stats_test);
disp('  Node Degrees:'); disp(stats_test.degree);

disp('2. Testing Star Graph: make_star(4)');
G_test = make_star(4);
disp('  Adjacency Matrix:'); disp(G_test);
stats_test = graph_stats(G_test);
disp('  Graph Statistics:'); disp(stats_test);
disp('  Node Degrees:'); disp(stats_test.degree);

disp('3. Testing Ring Graph: make_ring(5,1)');
G_test = make_ring(5,1);
disp('  Adjacency Matrix:'); disp(G_test);
stats_test = graph_stats(G_test);
disp('  Graph Statistics:'); disp(stats_test);
disp('  Node Degrees:'); disp(stats_test.degree);

disp('4. Testing Disk Graph: make_disk([0 0; 1 0; 3 0], 1.5)');
P_test = [0 0; 1 0; 3 0];
G_test = make_disk(P_test,1.5);
disp('  Adjacency Matrix:'); disp(G_test);
stats_test = graph_stats(G_test);
disp('  Graph Statistics:'); disp(stats_test);
disp('  Node Degrees:'); disp(stats_test.degree);

save('deployment_parameters.mat', 'P0', 'r_min', 'k');
disp('>>> Variables P0, r_min, and k successfully saved to deployment_parameters.mat');
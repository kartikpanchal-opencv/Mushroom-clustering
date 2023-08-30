%% 
% LOADING THE DATA

mushroom = readtable("agaricus-lepiota.data","FileType","text","TreatAsMissing",'?')
df_mushroom = mushroom;
%% 
% DATA ANALYSIS

% summary(df_mushroom);
% head(df_mushroom);
% height(df_mushroom)
% width(df_mushroom)
% countlabels(df_mushroom.p)
%% 
% DATA CLEAING

%Removing all the rows with '?' data
missing = ismissing(df_mushroom);
sum(missing,"all")
remaining_table = rmmissing(df_mushroom);
%% 
% DATA PRE-PROCESSING AND LABEL ENCODING

% Create a categorical array for entire table
for col = 1:size(remaining_table,2)
    if numel(unique(remaining_table(:, col))) == 5
        remaining_table.(col) = categorical(remaining_table.(col));
    end
end

% Convert the categorical values to numeric using grp2idx for computer to
% understand
for col = 1:size(remaining_table, 2)
    if iscellstr(remaining_table.(col))
        [idx, ~] = grp2idx(remaining_table.(col));
        remaining_table.(col) = idx;
    end
end

% Display the updated DataFrame
disp(remaining_table);
%% 
% CLUSTERING

x = remaining_table(:,:)
size(x)
mat = table2array(x)
norm_x = normalize(mat) 
norm_x(:,17) = []; %removing rows with NaN values
%% 
% K MEANS CLUSTERING

% Perform k-means clustering using specified number of clusters (K value)
K = 2;
[clusterIndices,centroids] = kmeans(norm_x,K);

% Display results

% Display 2D scatter plot (PCA)
figure
[~,score] = pca(norm_x);
clusterMeans = grpstats(score,clusterIndices,"mean");
h = gscatter(score(:,1),score(:,2),clusterIndices);
for i = 1:numel(h)
    h(i).DisplayName = strcat("Cluster",h(i).DisplayName);
end
clear h i score
hold on
h = scatter(clusterMeans(:,1),clusterMeans(:,2),50,"kx","LineWidth",2);
hold off
h.DisplayName = "ClusterMeans";
clear h clusterMeans
legend;
title("First 2 PCA Components of Clustered Data");
xlabel("First principal component");
ylabel("Second principal component");

xlim([-2.75 8.99])
ylim([-3.91 2.70])

% Matrix plot
figure
selectedCols = sort([1,2,3,4]);
[~,ax] = gplotmatrix(norm_x(:,selectedCols),[],clusterIndices,[],[],[],[],"grpbars");
title("Comparison of Columns in Clustered Data");
clear K
clusterMeans = grpstats(norm_x,clusterIndices,"mean");
hold(ax,"on");
for i = 1 : size(selectedCols,2)
  for j = 1 : size(selectedCols,2)
      if i ~= j  
          scatter(ax(j,i),clusterMeans(:,selectedCols(i)),clusterMeans(:,selectedCols(j)), ...
            50,"kx","LineWidth",1.5,"DisplayName","ClusterMeans");
          xlabel(ax(size(selectedCols,2),i),("Column" + selectedCols(i)));
          ylabel(ax(i,1),("Column" + selectedCols(i)));
      end
   end
end
clear ax clusterMeans i j selectedCols
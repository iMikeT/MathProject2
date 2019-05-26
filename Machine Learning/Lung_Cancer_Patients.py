import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn import preprocessing
from sklearn.model_selection import train_test_split 
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from sklearn.cluster import KMeans
from sklearn.cluster import AgglomerativeClustering

df = pd.read_excel(r'F:\Documents\University\Math Project\Project Year 4\Machine Learning\Job Example\Lung Cancer Patients\LUAD_fluxes.xlsx')
print(df.shape) # Matrix 517 x 7786 far too large
df1 = df.loc[:, (df != 0).any(axis=0)] # Remove all columns containing only zeros. Also creating duplicate dataset to work on
print(df1.shape) # Matrix 517 x 2980
df1 = df1.T.drop_duplicates().T # Remove all duplicate columns
print(df1.shape) # Matrix 517 x 2375
df1 = df1.dropna() # Remove rows with blanks in 'age'
print(df1.shape) # Matrix 508 x 2375 Now working with this dataframe

x = df1.iloc[:,np.arange(len(df1.columns))].values # Assign independent values to be the reaction flux rate
y = df1.iloc[:,-1].values                          # and dependent values to be 'days_to_death'



'''Supervised Learning Through Regression'''
xTrain, xTest, yTrain, yTest = train_test_split(x, y, test_size = 0.6, random_state = 42) # Testing on 95% of the data
model = LinearRegression() # A regression problem is when the output variable is a real value, such as 'days_to_death' here
model.fit(xTrain, yTrain)
yPrediction = model.predict(xTest)
#print(yTest)               # Visually compare Predicted results to actual Test results
#print(yPrediction)
print('Accuracy: ', r2_score(yTest, yPrediction))




#######################################################################




'''Unsupervised Learning through K-Means Clustering'''
# Standardize the data to normal distribution
df1_st = preprocessing.scale(x)
df1_st = pd.DataFrame(df1_st)

# Find the appropriate cluster number
plt.figure(figsize=(10, 8))
wcss = [] # Within-Cluster Sum of Squares
for i in range(1, 11):
    kmeans = KMeans(n_clusters = i, init = 'k-means++', random_state = 42)
    kmeans.fit(df1_st)
    wcss.append(kmeans.inertia_)
plt.plot(range(1, 11), wcss)
plt.title('The Elbow Method')
plt.xlabel('Number of clusters')
plt.ylabel('WCSS')
plt.show() # Bend at n_clusters = 5

# Fitting K-Means to the dataset
kmeans = KMeans(n_clusters = 5, init = 'k-means++', random_state = 42)
y_kmeans = kmeans.fit_predict(df1_st)
# Beginning of the cluster numbering with 1 instead of 0
y_kmeans1 = y_kmeans
y_kmeans1 = y_kmeans + 1
# New Dataframe called cluster
cluster = pd.DataFrame(y_kmeans1)
# Adding cluster to the Dataset1
df1['cluster'] = cluster
# Mean of clusters
kmeans_mean_cluster = pd.DataFrame(round(df1.groupby('cluster').mean(),1))
print(kmeans_mean_cluster)

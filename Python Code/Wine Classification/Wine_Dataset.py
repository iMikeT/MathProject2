import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Naive Bayes Classifier with Multiple Labels. Classify which type of wine given the features

# Loading Data
# Import scikit-learn dataset library
from sklearn import datasets
wine = datasets.load_wine()

# Exploring Data
# Print the names of the 13 features and 3 Labels
print("Features: ", wine.feature_names)
print()
print("Labels: ", wine.target_names)
print()
print("Wine data shape: ", wine.data.shape)
print()

# Print the wine data features (top 5 records)
print("First 5 rows of dataset: ", wine.data[0:5])
print()
# print the wine labels (0:Class_0, 1:class_2, 2:class_2)
print("Class that all 178 wines belong to: ", wine.target)
print()

# Splitting Data
# First, you separate the columns into dependent and independent variables(or features and label).
# Then you split those variables into train and test set.

# Import train_test_split function
from sklearn.cross_validation import train_test_split

# Split dataset into training set and test set
X_train, X_test, y_train, y_test = train_test_split(wine.data, wine.target, test_size=0.3,random_state=32) # 70% training and 30% test. EXPLINATION: https://scikit-learn.org/0.16/modules/generated/sklearn.cross_validation.train_test_split.html

# Model Generation
# After splitting, you will generate a random forest model on the training set and 
# perform prediction on test set features.
# Import Gaussian Naive Bayes model (EXPLINATION: https://scikit-learn.org/stable/modules/naive_bayes.html)
from sklearn.naive_bayes import GaussianNB

#Create a Gaussian Classifier
model = GaussianNB()

#Train the model using the training sets
model.fit(X_train, y_train)

#Predict the response for test dataset
predicted = model.predict(X_test)

# Evaluate Model
# After model generation, check the accuracy using actual and predicted values.
# Import scikit-learn metrics module for accuracy calculation. # EXPLINATION: https://scikit-learn.org/stable/modules/generated/sklearn.metrics.accuracy_score.html
from sklearn import metrics

# Model Accuracy, how often is the classifier correct?
print("Accuracy (Gaussian):",metrics.accuracy_score(y_test, predicted))
print()

#########################################################################
# Multinomial naive Bayes

X_train, X_test, y_train, y_test = train_test_split(wine.data, wine.target, test_size=0.3,random_state=32)
from sklearn.naive_bayes import MultinomialNB
model = MultinomialNB()
model.fit(X_train, y_train)
predicted = model.predict(X_test)
print("Accuracy (Multinomial):",metrics.accuracy_score(y_test, predicted))

#########################################################################
# Here is the loop for accuracy visualisation for Gaussian naive Bayes

v = np.zeros(50)
p = np.zeros(101)
u = np.zeros(101)
for i in range(1,len(p)):
    p[i] = p[i-1] + 0.01
    p[i] = round(p[i],2)
    for x in range(0, 50):
        if p[i] == 1.0:
            X_train, X_test, y_train, y_test = train_test_split(wine.data, wine.target, test_size=int(p[i]),random_state=x)
        else:
            X_train, X_test, y_train, y_test = train_test_split(wine.data, wine.target, test_size=round(p[i],2),random_state=x)
        model = GaussianNB()
        model.fit(X_train, y_train)
        predicted = model.predict(X_test) 
        v[x] = metrics.accuracy_score(y_test, predicted)
    u[i] = sum(v)/len(v)
u = np.flip(u)
u[len(u)-1] = 1
u[0] = 0
print(u)
sns.set_style("darkgrid")
fig = plt.figure(dpi=130)
ax = fig.add_subplot(1, 1, 1)
from matplotlib.ticker import PercentFormatter
plt.plot(p*100, u*100, 'r', linewidth=2)
ax.yaxis.set_major_formatter(PercentFormatter())
ax.xaxis.set_major_formatter(PercentFormatter())
plt.xticks(fontsize=10)
plt.yticks(fontsize=10)
plt.xlabel('Percentage of Data Used for Training', fontsize=12)
plt.ylabel('Percentage Accuracy of the Gaussian naive Bayes', fontsize=12)
plt.title('Predicting Wine Class with 13 Features', fontsize=16)
plt.show()

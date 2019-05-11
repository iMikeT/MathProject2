import pandas as pd
import numpy as np

# Naive Bayes Text Classifier
d = {'Text': ['A great game', 'The election was over', 'Very clean match', 'A clean but forgettable game', 'It was a close election', 'A very close game'],
     'Tag': ['Sports', 'Politics', 'Sports', 'Sports', 'Politics', 'Sports']}
Data = pd.DataFrame(data=d)
print()
print('Data Table')
print()
print(Data)
print()
Data['Text'] = Data['Text'].map(lambda Text: Text.lower()) # Remove case sensitive issue
Data['Text'] = Data['Text'].map(lambda Text: Text.split()) # To edit a column use .map(). .split() function that splits string with whitespace as delimiter.
print('Data Table')                                        # We will use work frequency to find probability of sentence being Sports or Not Sports.
print()                                                    # The 'Naive' part comes from assuming every work is independent of each other.
print(Data)
print()

# Want to classify 'A very close game' i.e. P(Sports|a very close game) > P(Politics|a very close game)

from collections import Counter
from collections import OrderedDict
class OrderedCounter(Counter, OrderedDict):
    pass
counterlist = OrderedCounter(x for xs in Data['Text'] for x in set(xs)) # Finding the frequency of each string in each list in the column Data['Text']
print(counterlist)
vocabulary = set(counterlist.keys())
print(counterlist.keys())
countervalue = sorted(counterlist.values())[::-1] # list(reversed(sorted(counterlist.values())))
print(countervalue)
print(len(counterlist))
p = {'Words': sorted(counterlist, key=counterlist.__getitem__)[::-1], 'Frequency': countervalue}
Freq = pd.DataFrame(data=p)
print()
print('Frequency Table')
print()
print(Freq)
print()

# Frequency Table
counterlistF = ['']*len(Data.index)
indexSports = []
indexNot = []
for i in range(0,len(Data.index)):
    Freq1 = pd.DataFrame(data=Data.iloc[i])
    Freq1 = Freq1.T
    counterlistF[i] = OrderedCounter(x for xs in Freq1['Text'] for x in set(xs))
    if list(Freq1['Tag']) == ['Sports']:
        indexSports.extend([i])
    else:
        indexNot.extend([i])
print('Rows that are Sports: ', indexSports)
wordsSports = []
for i in range(0,len(indexSports)):
    wordsSports.extend(sorted(counterlistF[indexSports[i]], key=counterlistF[indexSports[i]].__getitem__)[::-1])
counterlistS = Counter(wordsSports)
countervalueS = sorted(counterlistS.values())[::-1]
print(counterlistS)
p = {'Words in Sports': sorted(counterlistS, key=counterlistS.__getitem__)[::-1], 'Frequency': countervalueS}
FreqS = pd.DataFrame(data=p)
print()
print('Frequency Table for Sport')
print()
print(FreqS)
print()

print('Rows that are Politics: ', indexNot)
wordsNot = []
for i in range(0,len(indexNot)):
    wordsNot.extend(sorted(counterlistF[indexNot[i]], key=counterlistF[indexNot[i]].__getitem__)[::-1])
counterlistN = Counter(wordsNot)
countervalueN = sorted(counterlistN.values())[::-1]
print(counterlistN)
p = {'Words in Politics': sorted(counterlistN, key=counterlistN.__getitem__)[::-1], 'Frequency': countervalueN}
FreqN = pd.DataFrame(data=p)
print()
print('Frequency Table for Politics')
print()
print(FreqN)
print()

#############################################################

# Naive Bayes Machine Learning Section

d = {'Text': ['A great game', 'The election was over', 'Very clean match', 'A clean but forgettable game', 'It was a close election', 'A very close game'],
     'Tag': ['Sports', 'Politics', 'Sports', 'Sports', 'Politics', 'Sports']} # Change the last element in Text: and Tag: and see what the prediction is.
Data = pd.DataFrame(data=d)

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn import metrics

N = len(Data['Text'])
print(N)
n = N - 1 # Amount to train. Try to predict the last sentence
X_train = Data['Text'][:n]
Y_train = Data['Tag'][:n]
X_test = Data['Text'][n:N]
Y_test = Data['Tag'][n:N]

pipeline = Pipeline([
    ('vectorizer',  CountVectorizer(vocabulary=vocabulary)),
    ('classifier',  MultinomialNB()) # Laplace smoothing is on by default (alpha = 1)
])
pipeline.fit(X_train, Y_train)
predicted = pipeline.predict(X_test)
print('The sentence is predicted to be about: ', predicted)
print("Accuracy:",metrics.accuracy_score(Y_test, predicted)) # This gives either 100% or 0% since it's only predicting one sentence

# For the sentence 'Not a violent talk', the only training word here is 'a' which occurs in sports more 
# frequently: 2/11 for 'Sports' and 1/9 for 'Politics'. So the probabilities give 
# an incorrect prediction of 'Sports'

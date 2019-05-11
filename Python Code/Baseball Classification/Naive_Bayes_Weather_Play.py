# Will the team play or not based on weather conditions

import pandas as pd
import numpy as np

# Assigning features and label variables
d = {'Weather': ['Sunny','Sunny','Overcast','Rainy','Rainy','Rainy','Overcast','Sunny','Sunny','Rainy','Sunny','Overcast','Overcast','Rainy'],
     'Temperature': ['Hot','Hot','Hot','Mild','Cool','Cool','Cool','Mild','Cool','Mild','Mild','Mild','Hot','Mild'],
     'Play': ['No','No','Yes','Yes','Yes','No','Yes','No','Yes','Yes','Yes','Yes','Yes','No']}
Data = pd.DataFrame(data=d)
print('Data Table')
print()
print(Data)
print()

# Working with Weather and Play only
print('Working with Weather and Play only:')

# Frequency Tables
Freq = pd.crosstab(index=Data['Weather'], columns=Data['Play'], margins=True)
Freq.index = ['Overcast', 'Sunny', 'Rainy', 'Total']
Freq.columns = ['No', 'Yes', 'Total']
print('Frequency Tables')
print()
print(Freq)
print()

# Likelihood Table 1
Like1 = pd.DataFrame(data=Freq)
Like1['WeatherProb'] = ['4/14','5/14','5/14','']
Like1['WeatherProbDec'] = [4./14,5./14,5./14,'']
Like1 = Like1.append(pd.Series(['5/14', '9/14', '', '', ''], index=Like1.columns), ignore_index=True)
Like1 = Like1.append(pd.Series([5./14, 9./14, '', '', ''], index=Like1.columns), ignore_index=True)
Like1.index = ['Overcast', 'Sunny', 'Rainy', 'Total', 'PlayProb', 'PlayProbDec']
print('Likelihood Table 1')
print()
print(Like1)
print()

# Likelihood Table 2
Freq = pd.crosstab(index=Data['Weather'], columns=Data['Play'], margins=True)
Freq.index = ['Overcast', 'Sunny', 'Rainy', 'Total']
Freq.columns = ['No', 'Yes', 'Total']
Like2 = pd.DataFrame(data=Freq)
Like2['PostProb For No'] = ['0/5=0','2/5=0.4','3/5=0.6','']
Like2['PostProb For Yes'] = ['4/9=0.44','3/9=0.33','2/9=0.22','']
print('Likelihood Table 2')
print()
print(Like2)
print()

# Prob playing when it's overcast: p(Yes|Overcast) = p(Overcast|Yes)*p(Yes)/p(Overcast)
ProbYesRain = round(((2./9) * (9./14)) / (5./14),1)
print('p(Yes|Overcast) = ', ProbYesRain) # Prob of yes class is higher. So, If it's overcast then team will play.
print()
ProbNoRain = round(((3./5) * (5./14)) / (5./14),1)
print('p(No|Overcast) = ', ProbNoRain)
print()
print('Since 0.6 > 0.4, the team will not play.')
print()

##########################################################

# Working with full data
# Naive Bayes Classification with Binary Labels (i.e. Yes or No)
import sklearn
# Encoding features
from sklearn import preprocessing
LE = preprocessing.LabelEncoder() # Create label encoder
Weather_Encoded = LE.fit_transform(np.ravel(Data[['Weather']]))
Temperature_Encoded = LE.fit_transform(np.ravel(Data[['Temperature']]))
Play = LE.fit_transform(np.ravel(Data[['Play']]))
print('Weather: ', Weather_Encoded)          # 0: Overcast, 1: Rainy, 2: Sunny
print('Temperature: ', Temperature_Encoded)  # 0: Cool, 1: Hot, 2: Mild
print('Play: ', Play)                       # 0: N0, 1: Yes

# Combine both weather and temp features into a single variable (list of tuples)
Label = list(zip(Weather_Encoded, Temperature_Encoded))
print('Label: ', Label)

# Generate the model
print('\nRunning the Gaussian Naive Bayes Classifier with Weather and Temperature...\n')
Weather = input('Enter Weather Number (0: Overcast, 1: Rainy, 2: Sunny) and press Enter: ')
Temperature = input('\nEnter Temperature Number (0: Cool, 1: Hot, 2: Mild) and press Enter: ')
# Import Gaussian Naive Bayes model (EXPLINATION: https://scikit-learn.org/stable/modules/naive_bayes.html)
from sklearn.naive_bayes import GaussianNB
# Gaussian Classifier
model = GaussianNB()
# Train model using training sets
model.fit(Label, Play)
# Predict Output
predicted = model.predict([[int(Weather),int(Temperature)]]) # 0: Overcast, 1: Hot (IMPUT GOES HERE)
if(predicted == 1):
    print('\nYes, the team will play')
else:
    print('\nNo, the team will not play')
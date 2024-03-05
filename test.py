import streamlit as st
import nltk
from nltk.corpus import words
import pandas as pd

df = pd.read_csv('persons.csv')
st.multiselect('Select Persons', df, max_selections=10)

@st.cache_data
def load_words():
    nltk.download('words')
    word_set = set(words.words())
    word_list = list(word_set)
    word_list.sort()
    return word_list

# options = ("male", "female", "unk")
# i1 = st.multiselect("multiselect 1", options)
# st.text(f"value 1: {i1}")


#english_words = load_words()
#st.multiselect('Select English words', english_words, max_selections=3)

#my_list = list(range(1, 25000))
#st.multiselect('Select numbers between 1 and 25000', my_list)

# load the file persons.csv into a list




#st.write(df)

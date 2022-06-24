from konlpy.tag import Mecab

mecab = Mecab()

text = "아버지가 방에 들어가신다."

print(mecab.nouns(text))
print(mecab.morphs(text))

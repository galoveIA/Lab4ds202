library(readxl)
library(tidyverse)

defense <- read_excel('Lab 4 ds202/cyclonesFootball2020.xlsx', sheet = 'Defensive')
offense <- read_excel('Lab 4 ds202/cyclonesFootball2020.xlsx', sheet = 'Offensive')
bio <- read_excel('Lab 4 ds202/cyclonesFootball2020.xlsx', sheet = 'Biography')

# Part One

## Question 1

defense$Name <- factor(defense$Name)
defense$Opponent_Opponent <- factor(defense$Opponent_Opponent)

offense$Name <- factor(offense$Name)
offense$Opponent_Opponent <- factor(offense$Opponent_Opponent)

## Question 2

defense <- defense %>% mutate(across(c(3:11),as.numeric))

offense <- offense %>% mutate(across(c(3:12),as.numeric))

## Question 3
bioClean <- bio %>% separate(Height, c("Feet", "Inches"), sep = '-') %>% mutate(across(c(Feet, Inches), as.numeric)) %>% mutate(Height = Feet + (Inches/12)) %>% select(-Feet) %>% select(-Inches) %>% 
  select(c(Name, Position, Height, Weight, Class, Hometown, Highschool)) 
str(bioClean)

## Question 4

offClean <- offense %>% group_by(Name,Opponent_Opponent) %>% mutate(GameNumber = n()) %>% 
  mutate(GameNumber = case_when(!(row_number() %% 2 == 0)~ 1,(row_number() %% 2 == 0) ~2)) %>% ungroup()

str(offClean)

defClean <- defense %>% group_by(Name,Opponent_Opponent) %>% mutate(GameNumber = n()) %>% 
  mutate(GameNumber = case_when(!(row_number() %% 2 == 0)~ 1,(row_number() %% 2 == 0) ~2)) %>% ungroup()

str(defClean)

# Part Two

## Question 1

offClean <- offClean %>% pivot_longer(cols = 3:12, names_to = "stat", values_to = "vals")

## Question 2

pOffStats <- offClean %>% group_by(Name, stat) %>% summarise(totals = sum(vals)) 

## Question 3

pOffStats <- pOffStats %>% drop_na()
pOffStats <- pOffStats[!(pOffStats$stat == 'GameNumber'),]

plot <- ggplot(pOffStats, aes(x = Name, y = log10(totals))) + geom_bar(stat = "identity") + facet_wrap(~stat) + theme(axis.text.x = element_text(angle = 90))
plot

#One pattern I see is that the football team had many more people reciving than rushing for yards, but those who did rush earned more than those who recieved throughout the year. 
#Another pattern (which makes logical sense) is anyone who gained yards passing did not gain yards in recieving.

## Question 4

OorO <- offClean %>% filter(Opponent_Opponent == "Oregon" | Opponent_Opponent == "Oklahoma") %>% filter(stat == "Receiving_YDS") %>% drop_na()

plot <- ggplot(OorO, aes(x = Name, y = vals, color = Opponent_Opponent)) + geom_point()+ theme(axis.text.x = element_text(angle = 90))
plot

#We had better offense against Oklahoma, because for every player that played in both games, they had more rushing yards against oklahoma in at least one of the two games than they did against Oregon.

## Question 5

bioClean <- bioClean %>% separate(Hometown, c("City", "State"), sep = ', ')
head(bioClean)

## Question 6

stateSearch <- bioClean %>% group_by(State) %>% summarise(num = n()) %>% arrange(desc(num)) %>% print

## Question 7 

bDef <- defClean %>% group_by(Name) %>% select(Tackles_Solo) %>% summarise(tackles = sum(Tackles_Solo))
filter(bDef, Name == "Purdy, Brock")
mean(bDef$tackles)

#Brock had a substantially lower performance on Defense compared to his teammate, having only 1 tackle in the whole season as opposed to the team average of 9

bOff <- offClean %>% filter(stat == "Passing_YDS") %>% drop_na() %>% group_by(Name) %>% summarize(PassingYards = mean(vals)) %>% print

#On offense, Brock way outperformed his other quarterbacks, averaging 229 yards a game as opposed to 39.3 and 2.55 from his teammates.

# ⛓️ Memory Trainer

![game select page](./images/Screenshot%202023-05-29%20193556.png)

![Schulter Grid page](./images/Screenshot%202023-05-29%20192853.png)

![select page](./images/Screenshot%202023-05-29%20193556.png)

![start page](./images/Screenshot%202023-05-28%20211820.png)

![memory page](./images/Screenshot%202023-05-28%20211838.png)

![recall page](./images/Screenshot%202023-05-28%20211847.png)

![result page](./images/Screenshot%202023-05-28%20211858.png)

##Brain Trainer : Flutter application made by Ray Sheng

## 🧠 Design and Idea
Develop an Android app using Flutter. This app is designed to help practice brain memory.

🤔 SchulteGrid
A concentration training exercise using the Schulte Grid, in a 5x5 square grid, shuffle the numbers 1 to 25. Then, click on the numbers in ascending order from 1 to 25 as quickly as possible with a mouse. The person who completes the task accurately in the shortest time wins.

🤔 Endless Number
The first screen is to select levels. There are 3 levels required. Only the level one button is enabled at the start, the other buttons are disabled. The subsequent levels can only be enabled after the previous level is won.

The second screen is the level screen. Firstly, it randomly generates 40 two-digit numbers, each number is separated by a space. At the same time, there is a stopwatch at the top and an OK button at the bottom. Once the user presses OK, they enter the recall screen. On this screen, the user inputs the 40 numbers generated on the previous screen, and then presses OK, then enters the result screen. The program will compare whether the user has successfully memorized these numbers. The correctly remembered numbers are in blue, the wrong ones are in red, then it calculates the success rate. The success rate and the final time recorded in the stopwatch on the level screen are displayed at the bottom. If the success rate is 100%, the next level is successfully unlocked. The second level has 60 random numbers, and the third level has 80 random numbers and so on...

The program allows users to choose to exit the program at any screen. The user's score will be saved, and the next time the user can continue to challenge based on the level they won last time.

## Install
cd memorytrainer

flutter build apk --release

upload to mobile and install

## 💁 Study and Research
I am dedicated to the research and development of new technologies, including database, storage, AI, front-end, and back-end technologies. I am also engaged in the automatic control setup for creating intelligent homes.

[![Star History Chart](https://api.star-history.com/svg?repos=netcaster1/memorytrainer&type=Timeline)](https://star-history.com/#netcaster1/memorytrainer&Date)


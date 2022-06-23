# TIMETABLE-PROJECT
University (SEM 1) final project building CLI Timetable for students in Java

## TO RUN
Requirements:
- MySQL running with imported DB: ```theophilusarieldb.sql```

Note:<br/>
By the time of making, the past _me_ didn't use any ```env``` variable in the program, thus you'll need to make adjustment directly inside ```Main.java``` to match your environment 😜

Step-by-step:
1. Compile ```Main.java``` by running ```javac Main.java```
2. Run the code with the jar connector: ```java -cp .;./mysql-connector-java-8.0.18.jar Main```
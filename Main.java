//made by Theophilus Ariel IT 2020 SGU
//final exam Algorithm & OOP

import java.sql.*;
import java.util.Scanner;
import java.util.ArrayList;

public class Main {

	static final String url = "jdbc:mysql://localhost/theophilusarieldb";
	static final String username = "root";
	static final String password = "";

	static Connection con;
	static Statement st;
	static ResultSet rs;

	static int majorID; //to store the major_id
	static int semesterID; //to store the semester_id
	static int weekID; //to store the week_id

	static String major; //for dynamic headline
	static String semester; //for dynamic headline
	static String week; //for dynamic headline, week is not nessecary. Not accessed in other functions.


	public static void main(String[] args) {

		try {

			Class.forName("com.mysql.cj.jdbc.Driver");
			System.out.println("Made by Theophilus Ariel IT 2020 SGU");
			System.out.println("Establishing connection...");
			con = DriverManager.getConnection(url, username, password);
			st = con.createStatement();

			while (con != null) {

				showMajor();
				
			}

			st.close();
			con.close();

		} catch (Exception e) {
			System.out.println(e);
		}

	}

	static void showMajor() {

		try {

			String query = "CALL getAllMajor()";
			rs = st.executeQuery(query);

			//for headline
			System.out.println("\n+--------+----------------------------------+");
			System.out.println("| OPTION | MAJOR                            |");
			System.out.println("+--------+----------------------------------+");

			//for printing major list
			int count = 1;
			while (rs.next()) {
				System.out.printf("| %6d | %-32s |\n", count, rs.getString(1));
				count = count + 1;
			}
			System.out.println("+--------+----------------------------------+");

			//input majorID / EXIT
			//can use getUserAnswer() but no BACK option problem
			System.out.println("!TYPE 00 TO EXIT THE PROGRAM.");
			String tempMajorID = inputSTR("Input your major[1-12]: ");

			// to validate the input
			// we use a temp variable to check whether or not the input is valid
			if (tempMajorID.equals("00")) System.exit(0);

			try {
				//to convert back to int 
				majorID = Integer.parseInt(tempMajorID);
			} catch (NumberFormatException e) {
				//if the user decided to give an unexpected input
				System.out.println("\n!WRONG INPUT");
				return;
			}

			showSemester(); //whatever the major we will always show the semester			

		} catch (java.util.NoSuchElementException e) { //to handle ctrl + c, stop program if shell is not first
			System.exit(0);
		} catch (Exception e) {
			System.out.println(e);
		}

	}

	static void showSemester() {
		//for back function
		while (true) {

			try {

				// reason to put line 103 not in line 95 is because if we have exception the lines won't be printed
				// for printing headline M
				String getMajorNameQuery = "SELECT UPPER(major_name) FROM major WHERE major_id = " + majorID;
				try {

					rs = st.executeQuery(getMajorNameQuery);
					rs.next();
					major = rs.getString(1);
					
					System.out.print("\n+-------------------------------------------+");
					System.out.printf("\n| %-41s |\n", major); 

				} catch (Exception e) {
					System.out.println("\n!WRONG INPUT");
					return; //if there is exception from showMajor()
				}

				//for printing semester list
				String query = "CALL getAllSemester()";
				rs = st.executeQuery(query);

				System.out.println("+--------+----------------------------------+");

				int count = 1;
				while (rs.next()) {
					System.out.printf("| %6d | %-32s |\n", count, rs.getString(1));
					count = count + 1;
				}

				System.out.println("+--------+----------------------------------+");

				//input semesterID
				semesterID = getUserAnswer("Input your semester[1-8]: ");
				if (semesterID == 0) return; else if (semesterID != -1) showMenu(); //needs while loop!

			} catch (java.util.NoSuchElementException e) { //to handle ctrl + c, stop program if shell is not first
				System.exit(0);
			} catch (Exception e) {
				System.out.println(e);
			}

		}

	}

	static void showMenu() {
		while (true) {
			try {
			//for headline MS
				String getSemDescQuery = "SELECT semester_desc FROM semester WHERE semester_id = " + semesterID;
				rs = st.executeQuery(getSemDescQuery);
				rs.next();
				semester = rs.getString(1);
				System.out.print("\n+-------------------------------------------+");
				System.out.printf("\n| %-26s %-14s |\n", major, semester); 

			} catch (java.util.NoSuchElementException e) { // to handle ctrl + c, stop program if shell is not first
				System.exit(0);
			} catch (Exception e) {
				System.out.println("\n!WRONG INPUT");
				return; // to handle exception from choosing semester
			}

			//for printing menu
			System.out.println("+--------+----------------------------------+");
			System.out.println("|      1 | Show schedule                    |");
			System.out.println("|      2 | Insert schedule                  |");
			System.out.println("|      3 | Update schedule                  |");
			System.out.println("|      4 | Delete schedule                  |");
			System.out.println("|      5 | Course Info                      |");
			System.out.println("+--------+----------------------------------+");

			//input ansMenu
			int ansMenu = getUserAnswer("Input menu[1-5]: ");
			//-1 means error from getUserAnswer() - repeat the while loop on showMenu()
			if (ansMenu != -1) {
				switch (ansMenu) {
					case 1:
						// SHOW 14 WEEK OPTIONS
						showWeek();
						break;
					case 2:
						// insert schedule to db
						insertSchedule();
						break;
					case 3:
						// update schedule to db
						updateSchedule();
						break;
					case 4:
						// delete schedule from db
						deleteSchedule();
						break;
					case 5:
						// display course information, courseID, lecturer's name, room number, and major attending
						showCourseInfo();
						break;
					case 0:
						return;
					default:
						System.out.println("\n!WRONG INPUT"); //for invalid user answer
				}

			}
			
		}
		
	}

	static void showWeek() {

		while (true) {

			printWeekMS();

			//input weekID
			weekID = getUserAnswer("Input week[1-14]: ");
			if (weekID == 0) return; else if (weekID != -1) showSchedule(); //needs while loop!

		}

	}

	static void showSchedule() {

		while (true) {

			printScheduleMSW();

			//input answer BACK / EXIT
			while (true) {
				int ans = getUserAnswer("Input option[0/00]: ");
				if (ans == 0) return; else if (ans != -1) System.out.println("\n!WRONG INPUT\n");
			}

		}

	}

	static void insertSchedule() {

		int insertCourseID;
		String insertDate;
		ArrayList<Integer> insertTimeID = new ArrayList<Integer>(); //to store multiple timeslot input
		ArrayList<Integer> reportCount = new ArrayList<Integer>(); //to count total cells affected
		Scanner input = new Scanner(System.in).useDelimiter("[,\\s+]");

		printWeekMS();

		//input weekID
		while (true) { // for option to BACK / EXIT
			weekID = getUserAnswer("Insert schedule for week[1-14]: ");
			if (weekID == 0) return; else if (weekID != -1) break;
		}
		
		if (weekID == 0) 
			return; 
		else if (weekID != -1) {
			//show shcedule to insert
			printScheduleMSW();
			printCourseMSWithID();
			//input course id to insert
			while (true) { //for option to BACK / EXIT
				insertCourseID = getUserAnswer(String.format("Course [ID] to insert in [WEEK %d]: ", weekID));
				if (insertCourseID == 0) return; else if (insertCourseID != -1) break;
			}
			//input date
			System.out.println("!DATE INPUT FORMAT [YYYY-MM-DD]");
			insertDate = inputSTR(String.format("Insert date in [WEEK %d]: ", weekID));
			//input timeslot
			printTimeWithID();
			System.out.println("!YOU CAN INSERT SCHEDULE IN MULTIPLE TIMESLOT SEPERATED WITH \",\" EX. 1,2,3");
			System.out.print("Insert to timeslot: ");
			while (input.hasNext()) {
				if (input.hasNextInt()) 
					insertTimeID.add(input.nextInt());
				else 
					break;
			}

			//insert schedule to db
			try {

				for (int i = 0; i < insertTimeID.size(); i++) {
					String query = "CALL insertScheduleCDTSM(%d, '%s', %d, %d, %d)";
					query = String.format(query, insertCourseID, insertDate, insertTimeID.get(i), semesterID, majorID);
					//later count the size of reportCount
					/*since the query works by inserting 1 row per loop, to record the cells affected
					  we need to use arraylist and then count the size*/
					 //st.executeUpdate, runs the query and returns the number of affected row
					reportCount.add(st.executeUpdate(query)); 
				}
				System.out.printf("\n!SCHEDULE INSERTED SUCCESSFULLY - %d CELL(S) AFFECTED", reportCount.size());
				
			} catch (Exception e) {
				System.out.println(e);
			}

			//to remove all elements from the list for future use
			insertTimeID.clear(); 
			reportCount.clear(); 

			//print schedule to check
			printScheduleMSW();
			int ans = getUserAnswer("Input option[0/00]: ");
			if (ans == 0) return; else if (ans != -1) System.out.println("\n!WRONG INPUT\n");

		}

	}

	static void updateSchedule() {

		int toUpdateCourseID;
		int newCourseID;
		String toUpdateDate;
		String newDate;
		ArrayList<Integer> toUpdateTimeID = new ArrayList<Integer>();
		ArrayList<Integer> newTimeID = new ArrayList<Integer>();
		ArrayList<Integer> reportCount = new ArrayList<Integer>();
		Scanner input = new Scanner(System.in).useDelimiter("[,\\s+]");
		Scanner input2 = new Scanner(System.in).useDelimiter("[,\\s+]");

		printWeekMS();

		//input 
		weekID = getUserAnswer("Input week[1-14] schedule to insert: ");

		//check if there're existing curse, if not do not let user update
		if (checkExistingCourseMSW()) {

			if (weekID == 0) {
				return;
			} else if (weekID != -1) {
				printScheduleMSW();
				printExistingCourseMSW();
				//input course id to update
				while (true) {
					toUpdateCourseID = getUserAnswer(String.format("Course [ID] to be updated in [WEEK %d]: ", weekID));
					if (toUpdateCourseID == 0) return; else if (toUpdateCourseID != -1) break;
				}	
				//input date
				System.out.println("!DATE INPUT FORMAT [YYYY-MM-DD]");
				toUpdateDate = inputSTR(String.format("Insert schedule's date to be updated in [WEEK %d]: ", weekID));
				//input timeslot
				printTimeWithID();
				System.out.println("!YOU CAN UPDATE SCHEDULE IN MULTIPLE TIMESLOT SEPERATED WITH \",\" EX. 1,2,3");
				System.out.print("Insert schedule's timeslot to be updated: ");
				while (input.hasNext()) {
					if (input.hasNextInt()) 
						toUpdateTimeID.add(input.nextInt());
					else 
						break;
				}

				//input new course
				printCourseMSWithID();
				newCourseID = inputINT(String.format("New course [ID] for update in [WEEK %d]: ", weekID));
				//input new date
				System.out.println("!DATE INPUT FORMAT [YYYY-MM-DD]");
				newDate = inputSTR(String.format("Insert new date for update in [WEEK %d]: ", weekID));
				//input new timeslot
				printTimeWithID();
				System.out.println("!YOU CAN UPDATE MULTIPLE TIMESLOT SEPERATED WITH \",\" EX. 1,2,3");
				System.out.print("Insert new timeslot for update: ");
				while (input2.hasNext()) {
					if (input2.hasNextInt()) 
						newTimeID.add(input2.nextInt());
					else 
						break;
				}

				//update schedule from db
				try {

					for (int i = 0; i < toUpdateTimeID.size(); i++) {
						String query = "CALL updateSchedule(%d, '%s', %d, %d, '%s', %d, %d, %d);";
						query = String.format(query, newCourseID, newDate, newTimeID.get(i), toUpdateCourseID, toUpdateDate, toUpdateTimeID.get(i), semesterID, majorID);
						//to record cells affected
						reportCount.add(st.executeUpdate(query)); 
					}
					System.out.printf("\n!SCHEDULE UPDATED SUCCESSFULLY - %d CELL(S) AFFECTED", reportCount.size());

				} catch (Exception e) {
					System.out.println(e);
				}

				//to remove all elements from the list for future use
				toUpdateTimeID.clear(); 
				newTimeID.clear();
				reportCount.clear(); 

				//print schedule to check
				printScheduleMSW();
				int ans = getUserAnswer("Input option[0/00]: ");
				if (ans == 0) return; else if (ans != -1) System.out.println("\n!WRONG INPUT\n");

			}

		} else {
			System.out.println("\n!NO EXISTING COURSE - CAN'T UPDATE ANY SCHEDULE");
		}

	}

	static void deleteSchedule() {

		int toDeleteCourseID;
		String toDeleteDate;
		ArrayList<Integer> toDeleteTimeID = new ArrayList<Integer>(); //to store multiple timeslot input
		ArrayList<Integer> reportCount = new ArrayList<Integer>(); //to count total cells affected
		Scanner input = new Scanner(System.in).useDelimiter("[,\\s+]");

		printWeekMS();

		//input weekID
		while (true) {
			weekID = getUserAnswer("Input week[1-14] schedule to delete from: ");
			if (weekID == 0) return; else if (weekID != -1) break; 
		}

		//check if there're existing curse, if not, do not let user delete
		if (checkExistingCourseMSW()) {

			if (weekID == 0)
				return;
			else if (weekID != -1) {
				//show shcedule to insert
				printScheduleMSW();
				printExistingCourseMSW();
				//input course id to delete
				while (true) {
					toDeleteCourseID = getUserAnswer(String.format("Course [ID] to be deleted in [WEEK %d]: ", weekID));
					if (toDeleteCourseID == 0) return; else if (toDeleteCourseID != -1) break;
				}
				//input date
				System.out.println("!DATE INPUT FORMAT [YYYY-MM-DD]");
				toDeleteDate = inputSTR(String.format("Insert schedule's date to be deleted in [WEEK %d]: ", weekID));
				//input timeslot
				printTimeWithID();
				System.out.println("!YOU CAN DELETE SCHEDULE IN MULTIPLE TIMESLOT SEPERATED WITH \",\" EX. 1,2,3");
				System.out.print("Insert schedule's timeslot to be updated: ");
				while (input.hasNext()) {
					if (input.hasNextInt()) 
						toDeleteTimeID.add(input.nextInt());
					else 
						break;
				}

				//delete schedule from db
				try {

					for (int i = 0; i < toDeleteTimeID.size(); i++) {
						String query = "CALL deleteScheduleCDTSM(%d, '%s', %d, %d, %d)";
						query = String.format(query, toDeleteCourseID, toDeleteDate, toDeleteTimeID.get(i), semesterID, majorID);
						//to record the number of cell's affected
						reportCount.add(st.executeUpdate(query)); 
					}
					System.out.printf("\n!SCHEDULE DELETED SUCCESSFULLY - %d CELL(S) AFFECTED", reportCount.size());

				} catch (Exception e) {
					System.out.println(e);
				}

				//to remove all elements from the list for future use
				toDeleteTimeID.clear(); 
				reportCount.clear(); 

				//print schedule to check
				printScheduleMSW();
				int ans = getUserAnswer("Input option[0/00]: ");
				if (ans == 0) return; else if (ans != -1) System.out.println("\n!WRONG INPUT\n");

			}

		} else {
			System.out.println("\n!NO EXISTING COURSE - CAN'T DELETE ANY SCHEDULE");
		}

	}

	static void showCourseInfo() {

		int courseID;

		printCourseMSWithID();
		//input course id to insert
		while (true) {
			courseID = getUserAnswer("COURSE [ID]: ");
			if (courseID == 0) return; else if (courseID != -1) break;
		}

		try {

			String query = "CALL getCourseInfoMSC(%d, %d, %d)";
			query = String.format(query, majorID, semesterID, courseID); 
			rs = st.executeQuery(query);
			rs.next();

			System.out.println("\nCOURSE INFO\n");
			System.out.println("Course name: " + rs.getString(1));
			System.out.println("Course [ID]: " + rs.getString(2));
			System.out.println("Room number: " + rs.getString(3));

			try {

				String getCourseLecturerQuery = "CALL getCourseLecturer(%d)";
				getCourseLecturerQuery = String.format(getCourseLecturerQuery, courseID);
				rs = st.executeQuery(getCourseLecturerQuery);
				System.out.print("Lecturer:");
				while (rs.next()) {
					if (!rs.isLast()) {
						System.out.print(" " + rs.getString(1) + ",");
					} else {
						System.out.print(" " + rs.getString(1));
					}
				}
				System.out.println("");

			} catch (Exception e) {
				System.out.println(e);
			} 
			

			try {

				String getAttendingMajorQuery = "CALL getAttendingMajor(%d)";
				getAttendingMajorQuery = String.format(getAttendingMajorQuery, courseID);
				rs = st.executeQuery(getAttendingMajorQuery);
				System.out.print("Attending major:");
				while (rs.next()) {
					if (!rs.isLast()) {
						System.out.print(" " + rs.getString(1) + ",");
					} else {
						System.out.print(" " + rs.getString(1));
					}

				}
				System.out.println("\n");

			} catch (Exception e) {
				System.out.println(e);
			}

			//print schedule to check
			int ans = getUserAnswer("Input option[0/00]: ");
			if (ans == 0) return; else if (ans != -1) System.out.println("\n!WRONG INPUT\n");


		} catch (java.util.NoSuchElementException e) {
			System.exit(0);
		} catch (Exception e) {
			System.out.println(e);
		}

	}

	//utility functions

	static void printWeekMS() {

		try {
			//for headline MS + SCHEDULE
			System.out.print("\n+-------------------------------------------+");
			System.out.printf("\n| %-27s%-5s SCHEDULE |\n", major, semester); 

			String query = "CALL getAllWeek()";
			rs = st.executeQuery(query);

			System.out.println("+--------+----------------------------------+");
			//for printing week list
			int count = 1;
			while (rs.next()) {
				System.out.printf("| %6d | %-32s |\n", count, rs.getString(1));
				count = count + 1;
			}
			System.out.println("+--------+----------------------------------+");

		} catch (Exception e) {
			System.out.println(e);
		}

	}

	static void printScheduleMSW() {

		try {

			// for printing MSW headline
			try {

				String getWeekDescQuery = "SELECT week_desc FROM week WHERE week_id = " + weekID;
				rs = st.executeQuery(getWeekDescQuery);
				rs.next();
				week = rs.getString(1);
				System.out.println("\n+----------------------------------------------------------------------------------------------------------------------------------+");
				System.out.printf("| %-26s %s %-95s |\n", major, semester, week);

			} catch (Exception e) {
				System.out.println("\n!WRONG INPUT");
				return;
			}

			System.out.println("+---------------+----------------------+----------------------+----------------------+----------------------+----------------------+");

			// for printing day headline
			try {

				String getDayDEscQuery = "SELECT day_desc FROM day ORDER BY day_id ASC";
				rs = st.executeQuery(getDayDEscQuery);
				System.out.print("| TIME          |");
				while (rs.next()) {
					System.out.printf(" %-20s |", rs.getString(1));
				}

			} catch (Exception e) {
				System.out.println(e);
			}

			System.out.println("\n+---------------+----------------------+----------------------+----------------------+----------------------+----------------------+");

			// for printing date headline
			try {

				String getDateQuery = "CALL getDateForHeadline(%d)"; //can't use normal query - there's a problem in DATE_FORMAT(date_desc, "%d.%m.%Y") percent syntax
				getDateQuery = String.format(getDateQuery, weekID);
				rs = st.executeQuery(getDateQuery);
				System.out.print("|               |");

				while (rs.next()) {
					System.out.printf(" %-20s |", rs.getString(1));
				}

			} catch (Exception e) {
				System.out.println(e);
			}

			// for printing schedule content
			String query = "CALL getScheduleMSW(%d, %d, %d)";
			query = String.format(query, majorID, semesterID, weekID);

			System.out.println("\n+---------------+----------------------+----------------------+----------------------+----------------------+----------------------+");
			rs = st.executeQuery(query);
			while (rs.next()) {
				System.out.printf("| %s | %-20s | %-20s | %-20s | %-20s | %-20s |\n", rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6));
				System.out.println("+---------------+----------------------+----------------------+----------------------+----------------------+----------------------+");
			}

		} catch (Exception e) {
			System.out.println(e);
		}

	}

	static void printCourseMSWithID() {

		try {

			//for headline courseMS
			System.out.print("\n+-------------------------------------------+");
			System.out.printf("\n| %-27s%-14s |\n", major, semester);
			System.out.println("+--------+----------------------------------+");
			System.out.println(String.format("| %-6s | %-32s |", "ID", "COURSE"));
			System.out.println("+--------+----------------------------------+");

			String query = "CALL getCourseMS(%d, %d)";
			query = String.format(query, majorID, semesterID);
			rs = st.executeQuery(query);

			//for printing courseMS list
			while (rs.next()) {
				System.out.printf("| %6d | %-32s |\n", rs.getInt(1), rs.getString(2));
			}
			System.out.println("+--------+----------------------------------+");


		} catch (Exception e) {
			System.out.println(e);
		}

	}

	static void printExistingCourseMSW() {

		try {

			String query = "CALL getExistingCourseMSW(%d, %d, %d)";
			query = String.format(query, majorID, semesterID, weekID);
			rs = st.executeQuery(query);

			//for headline existing courseMSW
			System.out.print("\n+-------------------------------------------+");
			System.out.print(String.format("\n| %-41s |", "EXISTING COURSE"));
			System.out.print("\n+-------------------------------------------+");
			System.out.printf("\n| %-27s%-6sWEEK %-3s |", major, semester, weekID);
			System.out.print("\n+--------+----------------------------------+\n");

			//for printing existing courseMSW list 
			while (rs.next()) {
				System.out.printf("| %6d | %-32s |\n", rs.getInt(1), rs.getString(2));
			}
			System.out.println("+--------+----------------------------------+");

		} catch (Exception e) {
			System.out.println(e);
		}

	}

	//used in update and delete - don't let user update or delete if there aren't any existing course
	static boolean checkExistingCourseMSW() {

		try {

			String query = "CALL getExistingCourseMSW(%d, %d, %d)";
			query = String.format(query, majorID, semesterID, weekID);
			rs = st.executeQuery(query);
			if (rs.next()) {
				return true;
			}

		} catch (Exception e) {
			System.out.println(e);
		}

		return false;
	}

	static void printTimeWithID() {

		try {

			//for printing time headline
			System.out.println("+--------+----------------------------------+");
			System.out.println(String.format("| %-6s | %-32s |", "ID", "TIMESLOT"));
			System.out.println("+--------+----------------------------------+");

			String query = "CALL getTime()";
			rs = st.executeQuery(query);

			//for printing time list content
			while (rs.next()) {
				System.out.printf("| %6d | %-32s |\n", rs.getInt(1), rs.getString(2));
			}
			System.out.println("+--------+----------------------------------+");

		} catch (Exception e) {
			System.out.println(e);
		}

	}

	static int getUserAnswer(String text) {
		//input OPTIONS / BACK / EXIT
		System.out.println("!TYPE 0 TO GO BACK");
		System.out.println("!TYPE 00 TO EXIT THE PROGRAM.");
		String temp = inputSTR(text);
		//check 0 or 00
		if (temp.equals("0")) {
			return 0;
		} else if (temp.equals("00")) {
			System.exit(0);
		}
		//convert back to int
		//declare and initiallize for line 364 to understand
		int x = 0;
		try {
			x = Integer.parseInt(temp);
		} catch (NumberFormatException e) {
			System.out.println("\n!WRONG INPUT\n");
			return -1; //indicating error input
		} 

		return x;

	}

	static int inputINT(String txt) {
		Scanner input = new Scanner(System.in);
		System.out.print(txt);
		int x = input.nextInt();
		return x;
	}

	static String inputSTR(String txt) {
		Scanner input = new Scanner(System.in);
		System.out.print(txt);
		String x = input.nextLine();
		return x;
	}
}



CREATE TABLE `like` (
  ID INT PRIMARY KEY AUTOINCREMENT,
  postID INT,
  commentID INT,
  userID INT NOT NULL,
  CONSTRAINT FK_postID FOREIGN KEY (postID) REFERENCES post (ID) ON DELETE CASCADE,
  CONSTRAINT FK_commentID FOREIGN KEY (commentID) REFERENCES comment (ID) ON DELETE CASCADE,
  CONSTRAINT FK_userID FOREIGN KEY (userID) REFERENCES users (ID) ON DELETE CASCADE
);

CREATE TABLE comment (                                                      
  ID INTEGER PRIMARY KEY AUTOINCREMENT,                                   
  content TEXT NOT NULL,                                                  
  published BOOLEAN NOT NULL,                                             
  createdAt DATETIME NOT NULL,                                            
  authorID INTEGER,
  postID INTEGER,
  commentID INTEGER,                    
  CONSTRAINT FK_authorID FOREIGN KEY (authorID) REFERENCES users (id) ON DELETE CASCADE
);   

CREATE TABLE post (                                                         
  ID INTEGER PRIMARY KEY AUTOINCREMENT,                                   
  title TEXT NOT NULL,                                                    
  published BOOLEAN NOT NULL,                                             
  createdAt DATETIME NOT NULL,                                            
  authorID INTEGER, content TEXT,                                         
  CONSTRAINT FK_authorID FOREIGN KEY (authorID) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE users (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT password TEXT,
  password VARCHAR(30),
  email VARCHAR(100),
  tempCode VARCHAR(25),
  profilePic VARCHAR(255)
);

CREATE TABLE images (                                                  
  ID INT PRIMARY KEY AUTOINCREMENT,                                    
  postID INT NOT NULL,                                               
  uri VARCHAR(150) NOT NULL,                                         
  CONSTRAINT FK_postID FOREIGN KEY (postID) REFERENCES post (ID) ON DELETE CASCADE 
);    
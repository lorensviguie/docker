<html>
<body>

Hellooooooooooooo <?php echo $_POST["name"]; ?> 🐈
<br>
Your email address is: <?php echo $_POST["email"]; ?>
<br>
Everything has been sent to the database! (maybe it will work, or maybe it will explode because you didn't configure the database :( )

<?php
$host = '10.5.1.211';
$user = 'meo';
$password = 'meo';
$db = 'meo';
$conn = new mysqli($host, $user, $password, $db);
if (!$conn) {
    echo "Erreur de connexion à MariaDB<br />";
}
$sql = 'INSERT INTO meo (name, email) VALUES (?, ?)';
$stmt = $conn->prepare($sql);
if ($stmt) {
    $stmt->bind_param('ss', $_POST["name"], $_POST["email"]);
    $stmt->execute();
    $stmt->close();
}
$conn->close();
?>
<br><br>
<input type="button" value="Home" onClick="document.location.href='/'" />
</body>
</html>

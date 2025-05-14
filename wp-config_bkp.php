<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */
// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */

define('WP_CACHE', true);
define( 'WPCACHEHOME', '/home/factorit/public_html/wp-content/plugins/wp-super-cache/' );
define( 'DB_NAME', 'factorit_wp282' );
/** Database username */
define( 'DB_USER', 'factorit_wp282' );
/** Database password */
define( 'DB_PASSWORD', '7VSp.k9G3.' );
/** Database hostname */
define( 'DB_HOST', 'localhost' );
/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );
/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '8cyzrukoiqm6irdapmsrnz2iwgqbvrfijlxd0ta5gta18rv2cmrvi9nqbgwhabns' );
define( 'SECURE_AUTH_KEY',  '30zlinhccznfdzytndswncdspscji4cjgniuq2snxz0vrggvyui6dj7bielajglr' );
define( 'LOGGED_IN_KEY',    'aqchw5c6eijsmpvwkz5ome48dg29pvzktk3pgx5ridtghknlwcs5kczx6e2gnlvq' );
define( 'NONCE_KEY',        '3baoieppugassjrkoqy7dcjgrfiupw9erunpduncce5lwqe4nqgz688vyztulylg' );
define( 'AUTH_SALT',        '4fe9sbml2bezrfoehdbiufr1xsypgkz600mwnhjty6yyfo89effwzfybcfoyhoix' );
define( 'SECURE_AUTH_SALT', 'ihb5ckfzhqg4qmbaacgqeehqpwznc6fcbdl52flhq5jhtakaifyt1haekkbcx8z7' );
define( 'LOGGED_IN_SALT',   'qymuzqgm7j0jytczqxwxfwq645x51oje8qow3ijbp1nmslzibefxb7jihvtc9xc9' );
define( 'NONCE_SALT',       'q99alumar92xl0jgd5pbaw80ohf3wnd3yvapakfuuvhoe2aprllhi1kbvg83x6x3' );
/**#@-*/
/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wpih_';
/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );
define( 'WP_MEMORY_LIMIT', '512M' );

/* Configuraciones de seguridad */
// Forzar HTTPS para el panel de administración
define('FORCE_SSL_ADMIN', true);
define('FORCE_SSL_LOGIN', true);

// Configuración de cookies seguras
define('COOKIE_DOMAIN', $_SERVER['HTTP_HOST'] );
@ini_set('session.cookie_secure', 1);
@ini_set('session.cookie_httponly', 1);
@ini_set('session.use_only_cookies', 1);

// Desactivar editor de archivos en el panel de administración
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', false); // Permitir actualizaciones

// Limitar revisiones de posts para mejorar rendimiento
define('WP_POST_REVISIONS', 3);

// Configuración del cron de WordPress

/* Add any custom values between this line and the "stop editing" line. */
/* That's all, stop editing! Happy publishing. */
/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}
/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
    <footer>
        <div class="container">
            <div class="footer-menu">
                <?php
                wp_nav_menu( array(
                    'theme_location' => 'footer',
                    'menu_class'     => 'footer-menu',
                ) );
                ?>
            </div>
            <p>&copy; <?php echo date('Y'); ?> <?php bloginfo( 'name' ); ?>. Todos os direitos reservados.</p>
        </div>
    </footer>
    <?php wp_footer(); ?>
</body>
</html>
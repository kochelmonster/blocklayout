<div data-grid class="main-layout">
    left|content|right|[1]
    [1] |       |[1]
    </div>
    
    <div data-field="left" class="left"></div>
    <div data-field="right" class="right"></div>
    <div data-field="content" class="content">
        <header data-grid>
            climbing{c}|apartments{c}|booking{c}
        </header>
        <a data-field="climbing">Climbing</a>
        <Menu></Menu>
        
    <div class="video-wrapper">
          <video><source src="intro.mp4" type="video/mp4"/></video>
        </div>
        
        <footer>
        Impressum
        </footer>
    </div>
    
    
    <style>
    
    header {
        position: fixed;
        z-index: 10;
        width: 40em;
        background-color: #f5f5dc88;
        
    }
    
    .video-wrapper {
        width: 100%;
        height: 99vh;
        max-height: 99vh;
        -o-object-fit: cover;
        object-fit: cover;
        display: flex;
        box-sizing: border-box;
    }
    
    .video-wrapper video {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        -o-object-fit: cover;
        object-fit: cover;
    }
    
    .main-layout {
        min-height: 100%;
        padding: 1ex;
        box-sizing: border-box;
    }
    
    .right {
        min-width: 100px;
    }
    
    .content {
        width: 40em;
    }
    </style>
    
    
    <script>
    
    </script>
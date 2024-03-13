# video-player

## Project setup
```
npm install
```

### Electron development
```
npm run electron:serve
```

### Electron build
```
npm run electron:build
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### run chromium in kiosk mode
```
chromium --start-fullscreen --kiosk --app=http://localhost:8080
```


### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

### start up parameters
to setup a playlist include its id in the query param action. 
examples: 

```
http://localhost:8080&action=A      # starts playlist A
http://localhost:8080&action=B      # starts playlist A

http://localhost:8080&action=meta    # starts special view Meta (playlist of playlists)
```
# Welcome to plock.net

```ASCII art of plock.net
       _            _                 _   
      | |          | |               | |  
 _ __ | | ___   ___| | __  _ __   ___| |_ 
| '_ \| |/ _ \ / __| |/ / | '_ \ / _ \ __|
| |_) | | (_) | (__|   < _| | | |  __/ |_ 
| .__/|_|\___/ \___|_|\_(_)_| |_|\___|\__|
| |                                       
|_|                                       
```

## Blog Posts

{{ range (where .Site.Pages "Section" "articles") }}
=> {{ replace .Permalink "/gemini" "" 1}} {{ .Title }}
{{ end }}

The content for this site is CC-BY-SA. The code for this site is MIT.
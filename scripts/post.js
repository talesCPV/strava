
function new_element(tipo,innerHTML='',cls=0,id=0){
    const el = document.createElement(tipo)
    el.innerHTML = innerHTML
    if(cls){
        el.className = cls
    }
    if(id){
        el.id = id
    }
    return el
}

function setPost(obj){
    return  queryDB(obj,'POST-1')
}

function delPost(id,div){                   
    setPost({0:id,1:0,2:'',3:''}).then(()=>{
        div.remove()
    })
}

function getPost(data){
    const params = new Object;
        params.hash = localStorage.getItem('hash') != null ? localStorage.getItem('hash') : 0
        params.data = data
        params.start = main_data.dashboard.startPost
        params.limit = main_data.dashboard.limitPost    
    const myPromisse = queryDB(params,'POST-0')
    myPromisse.then((resolve)=>{
        const json = JSON.parse(resolve)      
        main_data.dashboard.startPost += json.length
        addPost(json)
    })
}

function getComm(id_post){
    const params = new Object;
        params.hash = localStorage.getItem('hash') != null ? localStorage.getItem('hash') : 0
        params.id_post = id_post
    return queryDB(params,'POST-3')
}

function likePost(id,div){

    const params = new Object;
        params.hash = localStorage.getItem('hash') != null ? localStorage.getItem('hash') : 0
        params.id = id
    if(params.hash){
        const myPromisse = queryDB(params,'POST-2')
        myPromisse.then((resolve)=>{
            const json = JSON.parse(resolve)[0]
            div.querySelector('p').innerHTML = json.LK
        })    
    }
}

function newComm(id,div){

    const comm = document.createElement('div')

    if(localStorage.getItem('hash') != null){
        comm.className = 'comments post'

        const ta = document.createElement('textarea')
        ta.className = 'post-new-comm'
        comm.appendChild(ta)

        const btn = document.createElement('button')
        btn.innerHTML = 'Postar'
        comm.appendChild(btn)

        btn.addEventListener('click',()=>{

            const params = new Object;
                params.id = 0
                params.id_parent = id
                params.nome = 'txt'
                params.texto = ta.value

            setPost(params).then((resolve)=>{
                const json =  JSON.parse(resolve)
                console.log(json)
                div.querySelector('.post-comm').innerHTML = ''
                for(let i=0; i<json.length; i++){
                    div.querySelector('.post-comm').appendChild(makePost(json[i]))
                }
            })
        })
        ta.focus()
    }
    return comm
}

function commentPost(id,div){

    const comments = div.querySelector('.post-comm')

    if(comments.innerHTML.length){
        comments.innerHTML = ''        
    }else{
        getComm(id).then((resolve)=>{
            const json = JSON.parse(resolve)
            for(let i=0; i<json.length; i++){
                comments.appendChild(makePost(json[i]))         
            }
            comments.appendChild(newComm(id,div))
        })
    }
}

function makePost(obj){

    const post = new_element('div','','post',`post-${obj.id}`)

    const head = new_element('div','','post-head')

    const head_left = new_element('div','','post-head-left')

    const img = new_element('img','','post-head-img')
    img.src = `assets/users/${obj.id_user}/perfil.jpg`
    head_left.appendChild(img)

    img.addEventListener('click',(e)=>{
        const tbl = []
        const mail = new Object
        mail.label = 'Ver Perfil'
        mail.link = ()=>{
            window.location.href = (window.location).toString()+'user-'+obj.id_user;
        }            
        tbl.push(mail)
        const user = new Object
        user.label = 'Ver Treinos'
        user.link = ()=>{
            window.location.href = (window.location).toString()+'tracks-'+obj.id_user;
        }            
        tbl.push(user)
        menuContext(tbl,e)
    })

    const head_name = new_element('div',obj.nome_usuario,'post-head-name')
    head_left.appendChild(head_name)
    head.appendChild(head_left)

    const head_rigth = new_element('div','','post-head-left')

    const subs_btn = new_element('div','Subscribe','post-btn')
    head_rigth.appendChild(subs_btn)

    const btn_more = new_element('div','...','btnMore')
    if(obj.owner=='1'){
        btn_more.addEventListener('click',(e)=>{
            const tbl = []
            const mail = new Object
            mail.label = 'Editar'
            mail.link = ()=>{
                obj.action = 'EDT'
                openHTML('post_new.html','pop-up','Edição...',obj,800)
            }            
            tbl.push(mail)
            const user = new Object
            user.label = 'Deletar'
            user.link = ()=>{
                if(confirm('Deseja deletar este post?')){
                    delPost(obj.id,post)
                }
            }            
            tbl.push(user)
            menuContext(tbl,e,0)
        })
    }
    head_rigth.appendChild(btn_more)
    head.appendChild(head_rigth)
    post.appendChild(head)


    if(obj.tipo == 'GPX'){
        const mov_h = Math.floor(obj.mov_time/3600).toString().padStart(2,0)
        const mov_m = Math.round(((obj.mov_time/3600)%1) * 60).toString().padStart(2,0)

        const post_track = new_element('div','','post-track')

        const track_name = new_element('div','','track-name')
        post_track.appendChild(track_name)
        track_name.appendChild(new_element('p',obj.nome))

        const track_data = new_element('div','','track-data')
        post_track.appendChild(track_data)

        const dist = new_element('div')
        dist.appendChild(new_element('p','distância'))
        dist.appendChild(new_element('p',obj.dist))
        dist.appendChild(new_element('p','Km'))
        track_data.appendChild(dist)

        const ele = new_element('div')
        ele.appendChild(new_element('p','Elevação'))
        ele.appendChild(new_element('p',obj.elev))
        ele.appendChild(new_element('p','m'))
        track_data.appendChild(ele)        

        const mov = new_element('div')
        mov.appendChild(new_element('p','Tempo Mov.'))
        mov.appendChild(new_element('p',`${mov_h}:${mov_m}`))
        mov.appendChild(new_element('p','h'))
        track_data.appendChild(mov)   

        post_track.addEventListener('click',()=>{
            openHTML('post_track.html','web-window',obj.nome,obj)
        })

        post.appendChild(post_track)
    }else{
        const post_text = new_element('div',obj.texto, 'post-text')
        post.appendChild(post_text)
    
    }

    const post_time = new_element('div','', 'post-time')
    post_time.innerHTML = `${obj.tipo == 'GPX'? obj.date_trk.viewXDate() : obj.cadastro.viewXDate()} - ${obj.VW} Views`
    post.appendChild(post_time)

    const post_social = new_element('div','', 'post-social')
    post.appendChild(post_social)

    const post_chat = new_element('div',`<span class="mdi mdi-chat-outline"></span><p>${obj.COMM}</p>`, 'post-social-chat')
    post_chat.addEventListener('click',()=>{
        commentPost(obj.id,post)
    })
    post_social.appendChild(post_chat)

    const post_like = new_element('div',`<span class="mdi mdi-thumb-up-outline"></span><p>${obj.LK}</p>`, 'post-social-chat')
    post_like.addEventListener('click',()=>{
        likePost(obj.id,post_like)
    })
    post_social.appendChild(post_like)

    const post_comm = new_element('div','', 'post-comm')
    post.appendChild(post_comm)

    return post
}

function addPost(obj){

    const screen = document.querySelector('#content-screen')
    for(let i=0; i<obj.length; i++){
        screen.appendChild(makePost(obj[i]))
    }


}
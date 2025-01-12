
function setPost(obj){
    return  queryDB(obj,'POST-1')
}


function delPost(id,div){                   
    setPost({0:id,1:0,2:'',3:'',4:'',5:0,6:''}).then(()=>{
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

function commentPost(id,div){
    console.log(div)
    getComm(id).then((resolve)=>{
        const json = JSON.parse(resolve)
        console.log(json)
        div.querySelector('.post-comm').innerHTML = json[0].texto
    })
/*    
    div.data.action = 'COMM'
    openHTML('post_new.html','pop-up','Comentarios',div.data)
*/
}

function addPost(obj){

    const screen = document.querySelector('#content-screen')
    for(let i=0; i<obj.length; i++){
        const post = document.createElement('div')
        post.id = `post-${obj[i].id}`
        post.data = obj[i]
        post.className = 'post'

        const head = document.createElement('div')
        head.className = 'post-head'

        const head_left = document.createElement('div')
        head_left.className = 'post-head-left'

        const img = document.createElement('img')
        img.className = 'post-head-img'
        img.src = `assets/users/${obj[i].id_user}/perfil.jpg`
        head_left.appendChild(img)

        const head_name = document.createElement('div')
        head_name.className = 'post-head-name'
        head_name.innerHTML = obj[i].nome_usuario
        head_left.appendChild(head_name)
        head.appendChild(head_left)

        const head_rigth = document.createElement('div')
        head_rigth.className = 'post-head-left'

        const subs_btn = document.createElement('div')
        subs_btn.className = 'post-btn'
        subs_btn.innerHTML = 'Subscribe'
        head_rigth.appendChild(subs_btn)

        const btn_more = document.createElement('div')
        btn_more.className = 'btnMore'
        btn_more.innerHTML = '...'
        if(obj[i].owner=='1'){
            btn_more.addEventListener('click',(e)=>{
                const tbl = []
                const mail = new Object
                mail.label = 'Editar'
                mail.link = ()=>{
                    obj[i].action = 'EDT'
                    openHTML('post_new.html','pop-up','Edição...',obj[i],800)
                }            
                tbl.push(mail)
                const user = new Object
                user.label = 'Deletar'
                user.link = ()=>{
                    if(confirm('Deseja deletar este post?')){
                        delPost(obj[i].id,post)
                    }
                }            
                tbl.push(user)
                menuContext(tbl,e,0)
            })
        }
        head_rigth.appendChild(btn_more)
        head.appendChild(head_rigth)
        post.appendChild(head)

        const post_text = document.createElement('div')
        post_text.className = 'post-text'
        post_text.innerHTML = obj[i].texto
        post.appendChild(post_text)

        const post_time = document.createElement('div')
        post_time.className = 'post-time'
        post_time.innerHTML = `${obj[i].cadastro.viewXDate()} - ${obj[i].VW} Views`
        post.appendChild(post_time)

        const post_social = document.createElement('div')
        post_social.className = 'post-social'
        post.appendChild(post_social)

        const post_chat = document.createElement('div')
        post_chat.className = 'post-social-chat'
        post_chat.innerHTML = `<span class="mdi mdi-chat-outline"></span><p>${obj[i].COMM}</p>`
        post_chat.addEventListener('click',()=>{
            commentPost(obj[i].id,post)
        })
        post_social.appendChild(post_chat)

        const post_like = document.createElement('div')
        post_like.innerHTML = `<span class="mdi mdi-thumb-up-outline"></span><p>${obj[i].LK}</p>`
        post_like.className = 'post-social-chat'
        post_like.addEventListener('click',()=>{
            likePost(obj[i].id,post_like)
        })
        post_social.appendChild(post_like)

        const post_comm = document.createElement('div')
        post_comm.className = 'post-comm'
        post.appendChild(post_comm)

        screen.appendChild(post)
    }


}
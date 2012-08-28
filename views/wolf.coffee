manage_mode = false

class @ManageWolf
  constructor: ->
    @member_count = $("ul.player-list li.player").size()
    @dead_count = 0

    @onloadSettings()

    @setImageZoomEvent()
    @setVoteResult()
    @setResetVote()
    @setManagePlayer()

    @setKillButtons()
    @setDateOperators()
    @setVote()
    @setCancelVote()

    @setAddRole()
    @setEditRole()

    # NOTE: モーダルを消す動作は最後に動作させる
    @setButtons()
    @setMask()

    @mask_remain = false

  onloadSettings: ->
    @reloadMemberCount()

  setImageZoomEvent: ->
    $("li.player").bind "click", @zoomImage
    $("li.player").bind "click", @zoomManage

  setVoteResult: ->
    $("div.sidebar-operations button#vote-result").bind "click", @voteResult

  setResetVote: ->
    $("div.sidebar-operations button#reset-vote").bind "click", @resetVote

  setManagePlayer: ->
    $("div.sidebar-operations button#manage-player").bind "click", @managePlayer
    $("div.sidebar-operations button#manage-end").bind "click", @managePlayerEnd

  setKillButtons: ->
    $("button.kill-button").bind "click", @killPlayer
    $("button#kill-cancel").bind "click", @killCancel

  setDateOperators: ->
    $("span.date-up").bind "click", @dateUp
    $("span.date-down").bind "click", @dateDown

  setVote: ->
    $("#modal button#vote").bind "click", @voteToPlayer

  setCancelVote: ->
    $("#modal button#vote-cancel").bind "click", @cancelVote

  setAddRole: ->
    $("button#add-role").bind "click", @addRole

  setEditRole: ->
    $("li.role label.edit-role").bind "click", @editRole
    $("li.role label.remove-role").bind "click", @removeRole
    $("li.role label.finish-edit").bind "click", @finishEdit

  setMask: ->
    $("#mask").bind "click", @hidePhoto
    $("#modal div.modal-name span.close").bind "click", @hidePhoto

  setButtons: ->
    $("#modal button").bind "click", @hidePhoto
    $("#modal button").bind "click", @reloadMemberCount
    $("span.date-up").bind "click", @reloadMemberCount
    $("span.date-down").bind "click", @reloadMemberCount

  reloadMemberCount: =>
    $("span#total").text(convertHalfToAll(@member_count))
    @dead_count = $("ul.player-list li.player img.kill-image").size()
    $("span#dead").text(convertHalfToAll(@dead_count))
    $("span#rest").text(convertHalfToAll(@member_count - @dead_count))

  zoomImage: (event) ->
    return false if manage_mode

    url = $(this).find("img").attr("src")
    name = $(this).find("span").text()
    id = $(this).attr("id")

    setModalImage = (name, url, id) ->
      modal = $("#modal")
      modal.find("div.modal-name span.player-name").text(name)
      modal.find("div.modal-image img").attr("src", url)
      modal.find("input#modal-id").attr("value", id)
      modal

    modal = setModalImage(name, url, id)
    modal.removeClass "hide"
    $("#mask").removeClass "hide"

  killPlayer: ->
    createKillImage = (kill_class, path) ->
      $("<img class=\"kill-image #{kill_class}\" src=\"#{path}\" width=\"128\" height=\"128\">")

    id = $("input#modal-id").attr("value")
    # NOTE: this = kill-button
    kill_button_id = $(this).attr("id")
    kill_image = switch kill_button_id
      when "day-kill-button"
        createKillImage("day-kill", "/images/day-kill.png")
      when "night-kill-button"
        createKillImage("night-kill", "/images/night-kill.png")

    # NOTE: player image change color to gray
    window.changeImage(id.replace(/-/, "-img-"))

    player_list = $("li##{id}")
    player_list.addClass "kill-player"
    player_list.find("img").remove("img.kill-image")
    player_list.append(kill_image)

    killed_day = "<span class=\"killed-day\">#{$("span.day-number").text()}日目 死亡　</span>"
    kill_image.after killed_day

  killCancel: ->
    player_id = $("input#modal-id").attr("value")

    # NOTE: player image restore original color
    window.reviveImage(player_id.replace(/-/, "-img-"))

    player_list = $("li##{player_id}")
    player_list.find("img").remove("img.kill-image")
    player_list.find("span.killed-day").remove("span.killed-day")
    player_list.removeClass "kill-player"

  voteToPlayer: =>
    createVoteNumberHtml = (number) ->
      if number.toString().length is 1
        number = "&nbsp;" + number.toString()
      "<p class=\"player-vote\">#{number}</p>"

    vote_number = $("#modal input.vote-number").val()

    if not(isNumber(vote_number)) or parseInt(vote_number) is 0
      alert("プレイヤーへの投票数を入力してください")
      @mask_remain = true
      return false
    @mask_remain = false

    vote_number_html = createVoteNumberHtml(vote_number)

    player_id = $("input#modal-id").attr("value")
    player_list = $("li##{player_id}")
    player_list.remove("p.player-vote")
    player_list.append(vote_number_html)

    $("#modal input.vote-number").val("0")

  cancelVote: ->
    player_id = $("input#modal-id").attr("value")
    $("li##{player_id} p.player-vote").remove("p.player-vote")

  voteResult: ->
    vote_list = $("ul.player-list p.player-vote")
    if vote_list.size() is 0
      alert("投票してから押してね")
      return false

    before_vote = $(vote_list[0])
    for vote in vote_list when parseInt($(vote).text()) > parseInt(before_vote.text())
      before_vote = $(vote)
    before_vote.parent("li.player").trigger "click"

  resetVote: ->
    $("ul.player-list li.player p").remove("p.player-vote")

  managePlayer: ->
    manage_mode = true
    $("div.sidebar-operations button#manage-player").addClass "hide"
    $("div.sidebar-operations button#manage-end").removeClass "hide"

    createAddPlayerTag = ->
      "<li class=\"add-player\">\
        <span>プレイヤー追加<br></span>\
        <img id=\"player-add\" width=\"128px\" height=\"128\" src=\"#{plusImage()}\">\
       </li>"

    add_player_image = createAddPlayerTag()

    $("ul.player-list").append(add_player_image)

  managePlayerEnd: ->
    manage_mode = false
    $("div.sidebar-operations button#manage-player").removeClass "hide"
    $("div.sidebar-operations button#manage-end").addClass "hide"

    $("li.add-player").remove()

  zoomManage: ->
    # TODO: zoom player manage modal


  dateUp: ->
    day = $("span.day-number").text()
    day_number = parseInt convertAllToHalf(day)
    day_number++
    $("span.day-number").text convertHalfToAll(day_number)

  dateDown: ->
    day = $("span.day-number").text()
    day_number = convertAllToHalf(day)
    return if day_number <= 0
    day_number--
    $("span.day-number").text convertHalfToAll(day_number)

  addRole: =>
    createRoleHtml = (name) ->
      "<li class=\"role\">\
        <label class=\"role-name\">#{name}</label>\
        <label class=\"role-number\">&nbsp;0</label>\
        <label class=\"edit-role\">編集</label>\
        <label class=\"remove-role\">削除</label>\
        <input type=\"text\" class=\"role-name hide\">\
        <input type=\"number\" class=\"role-number hide\" min=\"0\">\
        <label class=\"finish-edit hide\">完了</label>\
       </li>"

    role_name = prompt("役職名")
    return null unless role_name?

    role_html = createRoleHtml(role_name)
    $("ul.role-list li.add-role").before(role_html)

    $("li.role label.edit-role").unbind "click"
    $("li.role label.remove-role").unbind "click"
    $("li.role label.finish-edit").unbind "click"
    $("li.role label.edit-role").bind "click", @editRole
    $("li.role label.romove-role").bind "click", @removeRole
    $("li.role label.finish-edit").bind "click", @finishEdit

  editRole: ->
    role_row = $(this).parent("li.role")
    role_row.find(".hide").removeClass "hide"
    role_row.find("label.role-name").addClass "hide"
    role_row.find("label.role-number").addClass "hide"
    role_row.find("label.edit-role").addClass "hide"
    role_row.find("label.remove-role").addClass "hide"

    role_name = role_row.find("label.role-name").text()
    role_number = role_row.find("label.role-number").text()
    role_number = parseInt(role_number)
    role_row.find("input.role-name").val(role_name)
    role_row.find("input.role-number").val(role_number)

  removeRole: ->
    $(this).parent("li.role").remove("li.role")

  finishEdit: ->
    role_row = $(this).parent("li.role")

    role_number = role_row.find("input.role-number").val()
    unless isNumber(role_number)
      alert "人数は数字を入れてね。"
      return false

    if role_number.length is 1
      role_number = "&nbsp;" + role_number.toString()
    role_row.find("label.role-number").html(role_number)
    role_row.find("label.role-name").text(role_row.find("input.role-name").val())

    role_row.find(".hide").removeClass "hide"
    role_row.find("input").addClass "hide"
    role_row.find("label.finish-edit").addClass "hide"

  hidePhoto: =>
    if @mask_remain
      @mask_remain = false
      return false

    $("#mask").addClass "hide"
    $("#modal").addClass "hide"

isNumber = (value) ->
  not(isNaN(value))


convertAllToHalf = (number_string) ->
  number_string = number_string.replace(/１/g, "1")
  number_string = number_string.replace(/２/g, "2")
  number_string = number_string.replace(/３/g, "3")
  number_string = number_string.replace(/４/g, "4")
  number_string = number_string.replace(/５/g, "5")
  number_string = number_string.replace(/６/g, "6")
  number_string = number_string.replace(/７/g, "7")
  number_string = number_string.replace(/８/g, "8")
  number_string = number_string.replace(/９/g, "9")
  number_string = number_string.replace(/０/g, "0")

  parseInt number_string

convertHalfToAll = (number) ->
  number_string = number.toString()
  number_string = number_string.replace(/1/g, "１")
  number_string = number_string.replace(/2/g, "２")
  number_string = number_string.replace(/3/g, "３")
  number_string = number_string.replace(/4/g, "４")
  number_string = number_string.replace(/5/g, "５")
  number_string = number_string.replace(/6/g, "６")
  number_string = number_string.replace(/7/g, "７")
  number_string = number_string.replace(/8/g, "８")
  number_string = number_string.replace(/9/g, "９")
  number_string = number_string.replace(/0/g, "０")

  number_string = "　" + number_string if number_string.length is 1

  number_string

h = (value) ->
  $("<div/>").text(value).html()

plusImage = ->
  "data:image/png;base64,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"


<template>
  <div class="nameInput container">
    <div class="input-button">
      <input ref="name" :class="{ active: isActive }" @focus="isActive = true" @blur="(name.length === 0) ? isActive = false : isActive = isActive" type="text" v-model="name"/>
      <label>Gamer Name</label>
      <button class="btn btn-dark" @click.once="setUserName()" :disabled='!validateName(name)'>Find Match</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      name: "",
      isActive: false,
    };
  },
  created() {
    // this.$router.go();
  },
  watch: {
    name(value) {
      let len = 12;
      if (value.length < len) {
        this.name = value;
      } else {
        this.name = value.slice(0, len);
      }
    }
  },
  methods: {
    validateName(name) {
      return name !== "";

    },

    setUserName() {
      let socket = this.$store.getters.socket;
      let store = this.$store;

      this.$store.commit("setUserName", this.name);
      socket.emit("get_username", this.name);
      let data = {
        room_id: this.name + "-" + socket.id,
        username: this.name,
      };
      socket.emit("user_join_room", data);

      let set_current_player_and_room_id = new Promise((resolve, reject) => {
        if (!socket) {
          reject("No socket connection.");
        } else {
          store.getters.socket.on("set_current_player_and_room_id", (data) => {
            store.commit("setCurrentPlayer", data["player"]);
            store.commit("setRoomId", data["room_id"]);
            console.log("my room id is this -> " + store.getters.roomId);
            if (data["player"] === "X") {
              store.commit("setMyTurn", true);
            }
            resolve(store.getters.roomId);
          });
        }
      });

      set_current_player_and_room_id
          .then((roomid) => {
            // go  to the waiting screen if only one in room
            socket.on("waiting_for_opponent", () => {
              let url = "/waiting/" + roomid;
              this.$router.replace(url);
            });
            // go to the game screen if both player in room
            socket.on("match_found", () => {
              // send the username to the backend
              socket.emit("sendUserName", {
                name: store.getters.playerUserName,
                roomid: store.getters.roomId,
              });
              let url = "/game/" + roomid;
              this.$router.replace(url);
            });
          })
          .catch((err) => {
            console.log(err);
          });
    },
  },
};
</script>

<style scoped>
.nameInput {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  align-content: space-around;
  margin-top: 19vh;
  transform: scale(1.15);
}

.input-button {
  display: flex;
  flex-direction: column;
  row-gap: 2vh;
}

button {
  /* background: #673AB7; */
  background-image: linear-gradient(to right, #673AB7, #1AB6C3, #673AB7);
  background-size: 300% 100%;

  moz-transition: all .2s ease-in-out;
  -o-transition: all .2s ease-in-out;
  -webkit-transition: all .2s ease-in-out;
  transition: all .2s ease-in-out;
}

button:hover {
  background-position: 100% 0;
  moz-transition: all .2s ease-in-out;
  -o-transition: all .2s ease-in-out;
  -webkit-transition: all .2s ease-in-out;
  transition: all .2s ease-in-out;
}

button:disabled {
  background-color: #673AB7;
}


button:focus,
button:active {
  outline: 0 !important;
  outline: none !important;
  border: none !important;
  box-shadow: none !important;
}


input {
  font-family: inherit;
  width: 100%;
  border: 0;
  border-bottom: 2px solid #9b9b9b;
  outline: 0;
  font-size: 1.3rem;
  color: #f2f2f2;
  padding: 7px 0;
  background: transparent;
  transition: all 0.2s;
}

label {
  position: relative;
  right: 60px;
  bottom: 50px;
  transition: 0.2s;
  font-size: 1rem;
  color: #9b9b9b;
  pointer-events: none;
}

/* when thing is clicked */

.active {
  padding-bottom: 6px;
  border-width: 3px;
  border-image: linear-gradient(to right, #03DAC6, #673AB7);
  border-image-slice: 1;
}

.active ~ label {
  transition: 0.3s;
  bottom: 82px;
  background: -webkit-linear-gradient(0deg, #03DAC6, #9C67CD);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  font-weight: 700;
}

/* 03DAC6  9C67CD*/
</style>

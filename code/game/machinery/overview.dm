//#define AMAP

/obj/machinery/computer/security/verb/station_map()
	set name = ".map"
	set category = "Object"
	set src in view(1)
	usr.set_interaction(src)
	if(!mapping)	return

	log_game("[usr]([usr.key]) used station map L[z] in [src.loc.loc]")

	src.drawmap(usr)

/obj/machinery/computer/security/proc/drawmap(var/mob/user as mob)

	var/icx = round(world.maxx/16) + 1
	var/icy = round(world.maxy/16) + 1

	var/xoff = round( (icx*16-world.maxx)-2)
	var/yoff = round( (icy*16-world.maxy)-2)

	var/icount = icx * icy


	var/list/imap = list()

#ifdef AMAP

	for(var/i = 0; i<icount; i++)
		imap += icon('icons/misc/imap.dmi', "blank")
		imap += icon('icons/misc/imap.dmi', "blank")

	//to_chat(world, "[icount] images in list")


	for(var/wx = 1 ; wx <= world.maxx; wx++)

		for(var/wy = 1; wy <= world.maxy; wy++)

			var/turf/T = locate(wx, wy, z)

			var/colour
			var/colour2



			if(!T)
				colour = rgb(0,0,0)

			else
				var/sense = 1
				switch("[T.type]")
					if("/turf/open/space")
						colour = rgb(10,10,10)
						sense = 0

					if("/turf/open/floor")
						colour = rgb(150,150,150)
						var/turf/open/floor/TF = T
						if(TF.burnt == 1)
							sense = 0
							colour = rgb(130,130,130)

					if("/turf/open/floor/engine")
						colour = rgb(128,128,128)

					if("/turf/closed/wall")
						colour = rgb(96,96,96)

					if("/turf/closed/wall/r_wall")
						colour = rgb(128,96,96)

					if("/turf/open")
						colour  = rgb(240,240,240)

					else
						colour = rgb(0,40,0)




				if(sense)

					for(var/atom/AM in T.contents)

						if(istype(AM, /obj/machinery/door) && !istype(AM, /obj/machinery/door/window))
							if(AM.density)
								colour = rgb(96,96,192)
								colour2 = colour
							else
								colour = rgb(128,192,128)

						if(istype(AM, /obj/machinery/alarm))
							colour = rgb(0,255,0)
							colour2 = colour
							if(AM.icon_state=="alarm:1")
								colour = rgb(255,255,0)
								colour2 = rgb(255,128,0)

						if(istype(AM, /mob))
							if(AM:client)
								colour = rgb(255,0,0)
							else
								colour = rgb(255,128,128)

							colour2 = rgb(192,0,0)

				var/area/A = T.loc

				if(A.fire)

					var/red = getr(colour)
					var/green = getg(colour)
					var/blue = getb(colour)


					green = min(255, green+40)
					blue = min(255, blue+40)

					colour = rgb(red, green, blue)

			if(!colour2)
				colour2 = colour

			var/ix = round((wx*2+xoff)/32)
			var/iy = round((wy*2+yoff)/32)

			var/rx = ((wx*2+xoff)%32) + 1
			var/ry = ((wy*2+yoff)%32) + 1

			//to_chat(world, "trying [ix],[iy] : [ix+icx*iy]")
			var/icon/I = imap[1+(ix + icx*iy)*2]
			var/icon/I2 = imap[2+(ix + icx*iy)*2]


			//to_chat(world, "icon: \icon[I]")

			I.DrawBox(colour, rx, ry, rx+1, ry+1)

			I2.DrawBox(colour2, rx, ry, rx+1, ry+1)


	user.clearmap()

	user.mapobjs = list()


	for(var/i=0; i<icount;i++)
		var/obj/screen/H = new /obj/screen()

		H.screen_loc = "[5 + i%icx],[6+ round(i/icx)]"

		//to_chat(world, "\icon[I] at [H.screen_loc]")

		H.name = (i==0)?"maprefresh":"map"

		var/icon/HI = new/icon

		var/icon/I = imap[i*2+1]
		var/icon/J = imap[i*2+2]

		HI.Insert(I, frame=1, delay = 5)
		HI.Insert(J, frame=2, delay = 5)

		cdel(I)
		cdel(J)
		H.icon = HI
		H.layer = 25
		usr.mapobjs += H
#else

	for(var/i = 0; i<icount; i++)
		imap += icon('icons/misc/imap.dmi', "blank")

	for(var/wx = 1 ; wx <= world.maxx; wx++)

		for(var/wy = 1; wy <= world.maxy; wy++)

			var/turf/T = locate(wx, wy, z)

			var/colour

			if(!T)
				colour = rgb(0,0,0)

			else
				var/sense = 1
				switch("[T.type]")
					if("/turf/open/space")
						colour = rgb(10,10,10)
						sense = 0

					if("/turf/open/floor", "/turf/open/floor/engine")
						colour = rgb(2.55, 2.55, 255)

					if("/turf/closed/wall")
						colour = rgb(96,96,96)

					if("/turf/closed/wall/r_wall")
						colour = rgb(128,96,96)

					if("/turf/open")
						colour  = rgb(240,240,240)

					else
						colour = rgb(0,40,0)


				if(sense)

					for(var/atom/AM in T.contents)

						if(istype(AM, /obj/machinery/door) && !istype(AM, /obj/machinery/door/window))
							if(AM.density)
								colour = rgb(0,96,192)
							else
								colour = rgb(96,192,128)

						if(istype(AM, /obj/machinery/alarm))
							colour = rgb(0,255,0)

							if(AM.icon_state=="alarm:1")
								colour = rgb(255,255,0)

						if(istype(AM, /mob))
							if(AM:client)
								colour = rgb(255,0,0)
							else
								colour = rgb(255,128,128)

						//if(istype(AM, /obj/effect/blob))
						//	colour = rgb(255,0,255)

				var/area/A = T.loc

				if(A.flags_alarm_state & ALARM_WARNING_FIRE)

					var/red = getr(colour)
					var/green = getg(colour)
					var/blue = getb(colour)


					green = min(255, green+40)
					blue = min(255, blue+40)

					colour = rgb(red, green, blue)

			var/ix = round((wx*2+xoff)/32)
			var/iy = round((wy*2+yoff)/32)

			var/rx = ((wx*2+xoff)%32) + 1
			var/ry = ((wy*2+yoff)%32) + 1

			//to_chat(world, "trying [ix],[iy] : [ix+icx*iy]")
			var/icon/I = imap[1+(ix + icx*iy)]


			//to_chat(world, "icon: \icon[I]")

			I.DrawBox(colour, rx, ry, rx, ry)


	user.clearmap()

	user.mapobjs = list()


	for(var/i=0; i<icount;i++)
		var/obj/screen/H = new /obj/screen()

		H.screen_loc = "[5 + i%icx],[6+ round(i/icx)]"

		//to_chat(world, "\icon[I] at [H.screen_loc]")

		H.name = (i==0)?"maprefresh":"map"

		var/icon/I = imap[i+1]

		H.icon = I
		cdel(I)
		H.layer = 25
		usr.mapobjs += H

#endif

	user.client.screen += user.mapobjs

	src.close(user)

/*			if(seccomp == src)
				drawmap(user)
			else
				user.clearmap()*/
	return



/obj/machinery/computer/security/proc/close(mob/user)
	spawn(20)
		var/using = null
		if(user.mapobjs)
			for(var/obj/machinery/computer/security/seccomp in oview(1,user))
				if(seccomp == src)
					using = 1
					break
			if(using)
				close(user)
			else
				user.clearmap()


		return

proc/getr(col)
	return hex2num( copytext(col, 2,4))

proc/getg(col)
	return hex2num( copytext(col, 4,6))

proc/getb(col)
	return hex2num( copytext(col, 6))


/mob/proc/clearmap()
	src.client.screen -= src.mapobjs
	for(var/obj/screen/O in mapobjs)
		cdel(O)

	mapobjs = null
	src.unset_interaction()


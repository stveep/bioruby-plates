# TODO: Allow empty range field, Allow plate ranges
#
wellrange <- function(range,first="row"){
	#Check format
	if (!grepl("[A-Za-z]+\\d+-[A-Za-z]+\\d+",range)) {
		warning("Range must be of format A2-C4\n")
	}
	#Split out the start and end of the range
	range <- unlist(strsplit(range,"-"))
	if (length(range) > 2) { warning("More than one dash in range given") }
	range_start = range[1]
	range_end = range[2]
	range_start_row = toupper(sub("\\d+","",range_start))
	range_start_col = as.integer(sub("[A-Za-z]+","",range_start))
	range_end_row = toupper(sub("\\d+","",range_end))
	range_end_col = as.integer(sub("[A-Za-z]+","",range_end))
	# Append A for 1536 well plates
	letters = c(LETTERS,paste("A",LETTERS,sep=""))
	row_range = letters[which(letters==range_start_row):which(letters==range_end_row)]
	col_range = seq(from=range_start_col, to=range_end_col)

	if (first=="row") {
		first = row_range
		second = col_range
		label1="Row"
		label2="Column"
	} else {
		first = col_range
		second = row_range
		label2="Row"
		label1="Column"
	}
	output = data.frame(matrix(nrow=1,ncol=2))
	for (i in first) {
		for (j in second) {
			output <- rbind(output,c(i,j))
		}
	}
	names(output) <- c(label1,label2)
	#First row has NA values
	output <- output[-1,]
	#Sort by first then second (i.e. row then column default)
	#nchar needed to handle AA, AB... rows
	output[order(nchar(output[,1]),output[,1],as.integer(output[,2])),]
}

condition_wells <- function(wells,cname,value) {
	df <- wellrange(as.character(wells))
	df[,as.character(cname)]=value
	df

}

add_zero_to_single <- function(x) {
	if (as.integer(x) < 10) {
		paste("0",as.character(x),sep="")
	} else {
		x
	}
}

annotate_plate <- function(df,type=96,plate=1,area=2,condition=3,value=4) {
# For stuff replicated across plates, can use this with by functions
# DF provided needs Plate, Area, Condition, Value columns with indexes as in default args

	# set up the plate types
	nplates = length(unique(df[,plate]))
	if (type == 96) {
		fullplate = "A1-H12"
	} else {
		if (type == 384) {
			fullplate <- "A1-P24"
		} else {
			if (type == 1536) {
				fullplate <- "A1-AF48"
			}
		}
	}
	wells = wellrange(fullplate)
	# Apply the annotation
	# If Area is empty, apply to whole plate
	df[df[,area] == "",area] <- fullplate

	# If Plates field is empty, apply to all plates
	plate_empty <- df[is.na(df[,plate]),]
	if (nrow(plate_empty) != 0) {
	# Remove old empty plate rows
		df <- df[!is.na(df[,plate]),]

	# Makes a list of duplicate data frames, one for each plate
		new_rows <- lapply(unique(df[,plate]), function(x,pe) { temp = pe; temp$Plate = x; temp },pe=plate_empty)

	# Add the new ones
		new_rows$new = df
		df <- do.call(rbind,new_rows)

	}
	plate_ranges <- df[grep("-",df[,plate]),]
	# TODO: get range, make duplicate DF rows for each plate in range (as above)

	# Remove any lines where the condition or value is NA

	# Set up the plates data frame
	lst = list()
	for (i in unique(df[,plate])) {
		lst[[i]] = wells
		lst[[i]][,"Plate"] <- i
	}
	plates <- do.call(rbind, lst)

	#anno is a list of data frames
	#Now merge all of these with the plates data frame
	annolist = list()
	for (i in unique(df[,condition])) {
		anno <- df[df[,condition] == i,]
		# Expand well ranges
		anno <- apply(anno,1,function(x) {dft <- condition_wells(x[area],x[condition],x[value]); dft$Plate = x[plate]; dft})
	#	anno$plates <- plates
	#	annolist[[i]] <- Reduce(function(x,y) merge(x,y,by=c("Plate","Row","Column"),all=T), anno)
		tempplates <- plates
		for (j in anno) {
			tempplates <- merge(tempplates,j,all=T)
		}
		# Generates NAs for some reason, remove
		tempplates <- tempplates[!is.na(tempplates[,4]),]
		annolist[[i]] <- tempplates
	}
	red <- Reduce(function(x,y) merge(x,y,all=T),annolist)
	red <- red[!apply(red,1,function(x) any(is.na(x))),]
	# Add leading zeros and make a Well column by combining row + zerocolumn
	red$Well <- paste(red$Row, sapply(red$Column,add_zero_to_single),sep="")
	red[order(nchar(red$Row),red$Row,as.integer(red$Column)),]
}

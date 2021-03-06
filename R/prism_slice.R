#' Plot a slice of a raster stack
#' @description This function will plot a slice of data at a single point location from a list of prism files 
#' @param location a vector of a single location in the form of long,lat
#' @param prismfile a vector of output from ls_prism_data()[,1] giving a list of prism files to extract data from and plot
#' @return a ggplot2 plot of the requested slice
#' @details the list of prism files should be from a continuous data set. Otherwise the plot will look erratic and incorrect.
#' @examples \dontrun{
#' ### Assumes you have a clean prism directory
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=FALSE)
#' p <- prism_slice(c(-73.2119,44.4758),ls_prism_data())
#' print(p)
#' }
#' @import raster ggplot2 
#' @export


prism_slice <- function(location,prismfile){
  
  if(!is.null(dim(prismfile))){
    stop("You must enter a vector of file names, not a data frame, try  ls_prism_data()[,1]")
  }
  
  meta_d <- unlist(prism_md(prismfile,returnDate=T))
  meta_names <- unlist(prism_md(prismfile))[1]
  param_name <- strsplit(meta_names,"-")[[1]][3]

  pstack <- prism_stack(prismfile)
  data <- unlist(extract(pstack,matrix(location,nrow=1),buffer=10))
  data <- as.data.frame(data)
  data$date <- as.Date(meta_d)
  ## Re order
  data <- data[order(data$date),]
  if(grepl("tmin|tmax|tmean",rownames(data)[1])){
    u <- "(C)"
  } else if(grepl("ppt",rownames(data)[1])){
    u <- "(mm)"
  } else if(grepl("tdmean|vpdmax|vpdmin",rownames(data)[1])){
    u <- "hPA"
  }
    
  
  
  out <- ggplot(data,aes(x=date,y=data))+geom_path()+geom_point()+xlab("Date") + ylab(paste(param_name,u,sep=" "))
  
  return(out)
}
